package com.upence.util

object SenderParser {
    /**
     * India SMS Sender Format: XX-YYYYYY-Z
     * XX = Network Operator + Circle (2 chars)
     * YYYYYY = Business ID (6 chars)
     * Z = Classification (1 char with hyphen)
     *
     * Example: JD-KOTAKB-S
     * - JD = Jio + Delhi
     * - KOTAKB = Kotak Bank
     * - S = Service/Transactional
     */
    private val INDIA_SENDER_REGEX = Regex("^([A-Z]{2})-([A-Z0-9]{6})-([A-Z])$")

    data class ParsedSender(
        val prefix: String,
        val businessId: String,
        val classification: String,
        val senderName: String,
        val isIndiaFormat: Boolean,
    )

    fun parseSender(sender: String): ParsedSender {
        val match = INDIA_SENDER_REGEX.find(sender)

        return if (match != null) {
            val prefix = match.groupValues[1]
            val businessId = match.groupValues[2]
            val classification = match.groupValues[3]

            ParsedSender(
                prefix = prefix,
                businessId = businessId,
                classification = classification,
                senderName = "$businessId-$classification",
                isIndiaFormat = true,
            )
        } else {
            ParsedSender(
                prefix = "",
                businessId = "",
                classification = "",
                senderName = "",
                isIndiaFormat = false,
            )
        }
    }

    fun extractSenderName(sender: String): String {
        return parseSender(sender).senderName
    }
}
