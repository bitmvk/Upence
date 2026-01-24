package com.upence.util

import android.content.Context
import android.util.Log
import com.upence.data.AppDatabase
import com.upence.data.SMSParsingPattern
import com.upence.data.Transaction
import com.upence.data.TransactionType
import java.time.Instant

object SMSUtils {
    suspend fun parseTransactionFromSMS(
        context: Context,
        sender: String,
        message: String,
        onTransactionCreated: (Transaction) -> Unit = {},
    ): Transaction? {
        val database = AppDatabase.getDatabase(context)
        val patternDao = database.SMSParsingPatternDao()

        // Get active patterns for this sender
        val patterns = patternDao.getActivePatternsForSender(sender)

        if (patterns.isEmpty()) {
            Log.i("SMSUtils", "No active patterns found for sender: $sender")
            return null
        }

        // Find the best matching pattern based on message structure
        val bestPattern = findBestMatchingPattern(patterns, message)

        if (bestPattern == null) {
            Log.i("SMSUtils", "No pattern matched above threshold for sender: $sender")
            return null
        }

        try {
            val extractedData = extractDataUsingPattern(message, bestPattern.pattern)

            if (extractedData["amount"] != null && extractedData["counterparty"] != null) {
                Log.i("SMSUtils", "Successfully parsed transaction using pattern: ${bestPattern.pattern.patternName} (match score: ${bestPattern.matchScore})")

                // Update last used timestamp
                patternDao.updateLastUsedTimestamp(bestPattern.pattern.id, System.currentTimeMillis())

                // Create transaction
                val transaction =
                    Transaction(
                        counterParty = extractedData["counterparty"]!!,
                        amount = extractedData["amount"]!!.toDoubleOrNull() ?: 0.0,
                        timestamp = Instant.now(),
                        categoryID = "", // Will need to be set by user or default
                        description = "Auto-created from SMS: ${message.take(50)}",
                        accountID = "", // Will need to be set by user or default
                        transactionType = bestPattern.pattern.transactionType,
                        referenceNumber = extractedData["reference"] ?: "",
                    )

                onTransactionCreated(transaction)
                return transaction
            }
        } catch (e: Exception) {
            Log.w("SMSUtils", "Failed to parse with pattern ${bestPattern.pattern.patternName}: ${e.message}")
        }

        return null
    }

    fun extractDataUsingPattern(
        message: String,
        pattern: SMSParsingPattern,
    ): Map<String, String?> {
        val result = mutableMapOf<String, String?>()
        val words = message.split(Regex("""\s+""")).filter { it.isNotBlank() }

        // Extract amount
        if (pattern.amountPattern.isNotEmpty()) {
            val rawAmount = extractFromPositions(words, pattern.amountPattern)
            // Clean amount (extract numeric part only)
            var cleanAmount = rawAmount.replace("[^\\d.]".toRegex(), "")
            // Remove leading dots (e.g., ".1.00" -> "1.00")
            cleanAmount = cleanAmount.removePrefix(".")
            // Remove trailing dots (e.g., "1.00." -> "1.00")
            cleanAmount = cleanAmount.removeSuffix(".")
            if (cleanAmount.isNotBlank()) {
                result["amount"] = cleanAmount
            }
        }

        // Extract counterparty
        if (pattern.counterpartyPattern.isNotEmpty()) {
            result["counterparty"] = extractFromPositions(words, pattern.counterpartyPattern)
        }

        // Extract reference
        if (!pattern.referencePattern.isNullOrEmpty()) {
            result["reference"] = extractFromPositions(words, pattern.referencePattern)
        }

        // Extract date if pattern exists
        if (!pattern.datePattern.isNullOrEmpty()) {
            result["date"] = extractFromPositions(words, pattern.datePattern)
        }

        return result
    }

    private fun extractFromPositions(
        words: List<String>,
        positionPattern: String,
    ): String {
        val positions = positionPattern.split(",").mapNotNull { it.toIntOrNull() }
        return positions.mapNotNull { words.getOrNull(it) }.joinToString(" ").trim()
    }

    fun createPattern(
        sender: String,
        message: String,
        patternName: String,
        amountPositions: List<Int>,
        counterpartyPositions: List<Int>,
        referencePositions: List<Int>? = null,
        datePositions: List<Int>? = null,
        transactionType: TransactionType,
    ): SMSParsingPattern {
        return SMSParsingPattern(
            senderIdentifier = sender,
            patternName = patternName,
            messageStructure = buildMessageStructureFromPositions(message, amountPositions, counterpartyPositions, referencePositions, datePositions),
            amountPattern = amountPositions.joinToString(","),
            counterpartyPattern = counterpartyPositions.joinToString(","),
            datePattern = datePositions?.joinToString(","),
            referencePattern = referencePositions?.joinToString(","),
            transactionType = transactionType,
            isActive = true,
        )
    }

    private fun buildMessageStructureFromPositions(
        message: String,
        amountPositions: List<Int>,
        counterpartyPositions: List<Int>,
        referencePositions: List<Int>?,
        datePositions: List<Int>?,
    ): String {
        val words = message.split(Regex("""\s+""")).filter { it.isNotBlank() }
        return words.mapIndexed { index, word ->
            when {
                amountPositions.contains(index) -> "[AMOUNT]"
                counterpartyPositions.contains(index) -> "[COUNTERPARTY]"
                datePositions?.contains(index) == true -> "[DATE]"
                referencePositions?.contains(index) == true -> "[REFERENCE]"
                word.length > 3 -> "[TEXT]"
                else -> "[SHORT]"
            }
        }.joinToString(" ")
    }

    fun validateAmount(amount: String): Boolean {
        return amount.toDoubleOrNull() != null && amount.toDouble() > 0
    }

    fun buildMessageStructure(
        message: String,
        amountPositions: List<Int>,
        counterpartyPositions: List<Int>,
        referencePositions: List<Int>? = null,
        datePositions: List<Int>? = null,
    ): String {
        val words = message.split("\\s+".toRegex())
        return words.mapIndexed { index, word ->
            when {
                amountPositions.contains(index) -> "[AMOUNT]"
                counterpartyPositions.contains(index) -> "[COUNTERPARTY]"
                datePositions?.contains(index) == true -> "[DATE]"
                referencePositions?.contains(index) == true -> "[REFERENCE]"
                word.length > 3 -> "[TEXT]"
                else -> "[SHORT]"
            }
        }.joinToString(" ")
    }

    fun calculateStructureMatchScore(structure1: String, structure2: String): Double {
        val tokens1 = structure1.split(" ")
        val tokens2 = structure2.split(" ")

        if (tokens1.isEmpty() || tokens2.isEmpty()) return 0.0

        val minLength = minOf(tokens1.size, tokens2.size)
        var matchCount = 0

        for (i in 0 until minLength) {
            if (tokens1[i] == tokens2[i]) matchCount++
        }

        val positionPenalty = if (tokens1.size != tokens2.size) {
            0.1 * Math.abs(tokens1.size - tokens2.size)
        } else {
            0.0
        }

        val baseScore = matchCount.toDouble() / maxOf(tokens1.size, tokens2.size)
        val finalScore = baseScore - positionPenalty

        return maxOf(0.0, finalScore)
    }

    data class PatternMatchResult(
        val pattern: SMSParsingPattern,
        val matchScore: Double,
        val validationScore: Double,
        val isValid: Boolean,
    )

    fun findBestMatchingPattern(patterns: List<SMSParsingPattern>, message: String): PatternMatchResult? {
        if (patterns.isEmpty()) return null

        val threshold = 0.5

        // Filter out patterns with missing required fields
        val validInputPatterns = patterns.filter { pattern ->
            val hasAmount = pattern.amountPattern.isNotEmpty() && pattern.amountPattern.isNotBlank()
            val hasCounterparty = pattern.counterpartyPattern.isNotEmpty() && pattern.counterpartyPattern.isNotBlank()
            val isValid = hasAmount && hasCounterparty

            if (!isValid) {
                Log.w("SMSUtils", "  Pattern '${pattern.patternName}' skipped - missing fields (amount=${hasAmount}, counterparty=${hasCounterparty})")
            }

            isValid
        }

        if (validInputPatterns.isEmpty()) {
            Log.w("SMSUtils", "No valid patterns (all have missing required fields)")
            return null
        }

        val scoredPatterns = validInputPatterns.map { pattern ->
            val structureScore = calculateStructureMatchScoreForPattern(message, pattern)
            val validationResult = validatePatternMatch(message, pattern)
            val validationScore = validationResult.second

            PatternMatchResult(
                pattern = pattern,
                matchScore = structureScore,
                validationScore = validationScore,
                isValid = validationResult.first,
            )
        }

        Log.d("SMSUtils", "Pattern matching results for message: ${message.take(50)}...")
        scoredPatterns.forEach { result ->
            Log.d("SMSUtils", "  Pattern '${result.pattern.patternName}': score=${"%.2f".format(result.matchScore)}%, valid=${result.isValid}, validationScore=${"%.2f".format(result.validationScore)}%")
        }

        val validPatterns = scoredPatterns.filter { it.matchScore >= threshold && it.isValid }

        if (validPatterns.isEmpty()) {
            Log.w("SMSUtils", "No valid pattern found above threshold $threshold")
            return null
        }

        val bestPattern = validPatterns.maxByOrNull {
            it.matchScore * 0.6 + it.validationScore * 0.3 + (if (it.pattern.lastUsedTimestamp != null) 0.1 else 0.0)
        }

        Log.i("SMSUtils", "Best pattern selected: ${bestPattern?.pattern?.patternName} with score ${"%.2f".format(bestPattern?.matchScore ?: 0.0)}%")
        return bestPattern
    }

    private fun calculateStructureMatchScoreForPattern(message: String, pattern: SMSParsingPattern): Double {
        val words = message.split(Regex("""\s+""")).filter { it.isNotBlank() }

        val amountPositions = pattern.amountPattern.split(",").mapNotNull { it.toIntOrNull() }
        val counterpartyPositions = pattern.counterpartyPattern.split(",").mapNotNull { it.toIntOrNull() }
        val referencePositions = pattern.referencePattern?.split(",")?.mapNotNull { it.toIntOrNull() }
        val datePositions = pattern.datePattern?.split(",")?.mapNotNull { it.toIntOrNull() }

        val currentMessageStructure = buildMessageStructureFromPositions(words, amountPositions, counterpartyPositions, referencePositions, datePositions)
        val patternMessageStructure = pattern.messageStructure

        Log.d("SMSUtils", "Pattern '${pattern.patternName}' matching:")
        Log.d("SMSUtils", "  Current message structure: $currentMessageStructure")
        Log.d("SMSUtils", "  Pattern message structure:  $patternMessageStructure")
        Log.d("SMSUtils", "  Word count: ${words.size}")

        return calculateStructureMatchScore(currentMessageStructure, patternMessageStructure)
    }

    private fun buildMessageStructureFromPositions(
        words: List<String>,
        amountPositions: List<Int>,
        counterpartyPositions: List<Int>,
        referencePositions: List<Int>?,
        datePositions: List<Int>?,
    ): String {
        return words.mapIndexed { index, word ->
            when {
                amountPositions.contains(index) -> "[AMOUNT]"
                counterpartyPositions.contains(index) -> "[COUNTERPARTY]"
                datePositions?.contains(index) == true -> "[DATE]"
                referencePositions?.contains(index) == true -> "[REFERENCE]"
                word.length > 3 -> "[TEXT]"
                else -> "[SHORT]"
            }
        }.joinToString(" ")
    }

    fun buildMessageStructureFromMessage(message: String): String {
        val words = message.split(Regex("""\s+""")).filter { it.isNotBlank() }
        return words.mapIndexed { index, word ->
            when {
                word.contains("Rs\\.", ignoreCase = true) || word.matches(".*\\d+\\.?\\d*".toRegex()) -> "[AMOUNT]"
                word.contains("@") || word.matches(".*\\d+@.*".toRegex()) -> "[COUNTERPARTY]"
                word.matches("\\d{2}-\\d{2}-\\d{2}".toRegex()) || word.matches("\\d{2}/\\d{2}/\\d{2}".toRegex()) -> "[DATE]"
                word.startsWith("Ref", ignoreCase = true) || word.startsWith("UPI", ignoreCase = true) -> "[REFERENCE]"
                word.length > 3 -> "[TEXT]"
                else -> "[SHORT]"
            }
        }.joinToString(" ")
    }

    fun validatePatternMatch(message: String, pattern: SMSParsingPattern): Pair<Boolean, Double> {
        var validationScore = 1.0
        val extractedData = extractDataUsingPattern(message, pattern)
        var issues = mutableListOf<String>()

        Log.d("SMSUtils", "Validating pattern '${pattern.patternName}':")
        Log.d("SMSUtils", "  Amount pattern: '${pattern.amountPattern}'")
        Log.d("SMSUtils", "  Counterparty pattern: '${pattern.counterpartyPattern}'")
        Log.d("SMSUtils", "  Extracted data: $extractedData")

        val amount = extractedData["amount"]
        if (amount != null) {
            var cleanAmount = amount.replace("[^\\d.]".toRegex(), "")
            // Remove leading/trailing dots (e.g., ".1.00" -> "1.00", "1.00." -> "1.00")
            cleanAmount = cleanAmount.removePrefix(".").removeSuffix(".")
            val amountValue = cleanAmount.toDoubleOrNull()
            if (amountValue == null || amountValue <= 0) {
                validationScore -= 0.3
                issues.add("Invalid amount: $amount (cleaned: $cleanAmount)")
            }
        } else {
            validationScore -= 0.5
            issues.add("No amount extracted")
        }

        val counterparty = extractedData["counterparty"]
        if (counterparty != null) {
            val fillerWords = listOf("from", "to", "on", "your", "in", "with", "at", "by", "for")
            val counterpartyLower = counterparty.lowercase()
            if (fillerWords.any { counterpartyLower.contains(it) }) {
                validationScore -= 0.3
                issues.add("Counterparty contains filler words")
            }
        } else {
            validationScore -= 0.5
            issues.add("No counterparty extracted")
        }

        val reference = extractedData["reference"]
        if (!pattern.referencePattern.isNullOrEmpty() && reference != null) {
            if (!reference.matches(".*\\d+.*".toRegex())) {
                validationScore -= 0.2
                issues.add("Reference missing expected digits")
            }
        }

        Log.d("SMSUtils", "  Validation score: $validationScore, issues: $issues")
        return Pair(issues.isEmpty(), maxOf(0.0, validationScore))
    }
}
