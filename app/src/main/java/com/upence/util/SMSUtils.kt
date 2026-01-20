package com.upence.util

import android.content.Context
import android.util.Log
import com.upence.data.AppDatabase
import com.upence.data.SMSParsingPattern
import com.upence.data.Transaction
import com.upence.data.TransactionType
import kotlinx.coroutines.runBlocking
import java.time.Instant

object SMSUtils {

    suspend fun parseTransactionFromSMS(
        context: Context,
        sender: String,
        message: String,
        onTransactionCreated: (Transaction) -> Unit = {}
    ): Transaction? {
        val database = AppDatabase.getDatabase(context)
        val patternDao = database.SMSParsingPatternDao()
        
        // Get active patterns for this sender
        val patterns = patternDao.getActivePatternsForSender(sender)
        
        if (patterns.isEmpty()) {
            Log.i("SMSUtils", "No active patterns found for sender: $sender")
            return null
        }
        
        // Try each pattern until we find a match
        for (pattern in patterns) {
            try {
                val extractedData = extractDataUsingPattern(message, pattern)
                
                if (extractedData["amount"] != null && extractedData["counterparty"] != null) {
                    Log.i("SMSUtils", "Successfully parsed transaction using pattern: ${pattern.patternName}")
                    
                    // Update last used timestamp
                    patternDao.updateLastUsedTimestamp(pattern.id, System.currentTimeMillis())
                    
                    // Create transaction
                    val transaction = Transaction(
                        counterParty = extractedData["counterparty"]!!,
                        amount = extractedData["amount"]!!.toDoubleOrNull() ?: 0.0,
                        timestamp = Instant.now(),
                        categoryID = "", // Will need to be set by user or default
                        description = "Auto-created from SMS: ${message.take(50)}",
                        accountID = "", // Will need to be set by user or default
                        transactionType = pattern.transactionType,
                        referenceNumber = extractedData["reference"] ?: ""
                    )
                    
                    onTransactionCreated(transaction)
                    return transaction
                }
            } catch (e: Exception) {
                Log.w("SMSUtils", "Failed to parse with pattern ${pattern.patternName}: ${e.message}")
            }
        }
        
        return null
    }
    
    fun extractDataUsingPattern(message: String, pattern: SMSParsingPattern): Map<String, String?> {
        val result = mutableMapOf<String, String?>()
        val words = message.split("\\s+".toRegex())
        
        // Extract amount
        if (pattern.amountPattern.isNotEmpty()) {
            result["amount"] = extractFromPositions(words, pattern.amountPattern)
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
    
    private fun extractFromPositions(words: List<String>, positionPattern: String): String {
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
        transactionType: TransactionType
    ): SMSParsingPattern {
        return SMSParsingPattern(
            senderIdentifier = sender,
            patternName = patternName,
            messageStructure = buildMessageStructure(message, amountPositions, counterpartyPositions, referencePositions, datePositions),
            amountPattern = amountPositions.joinToString(","),
            counterpartyPattern = counterpartyPositions.joinToString(","),
            datePattern = datePositions?.joinToString(","),
            referencePattern = referencePositions?.joinToString(","),
            transactionType = transactionType,
            isActive = true
        )
    }
    
    private fun buildMessageStructure(
        message: String,
        amountPositions: List<Int>,
        counterpartyPositions: List<Int>,
        referencePositions: List<Int>?,
        datePositions: List<Int>?
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
    
    fun validateAmount(amount: String): Boolean {
        return amount.toDoubleOrNull() != null && amount.toDouble() > 0
    }
}
