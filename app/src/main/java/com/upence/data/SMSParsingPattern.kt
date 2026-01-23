package com.upence.data

import androidx.room.Entity
import androidx.room.PrimaryKey

@Entity(tableName = "sms_parsing_patterns")
data class SMSParsingPattern(
    @PrimaryKey(autoGenerate = true)
    val id: Int = 0,
    val senderIdentifier: String, // Phone number or sender ID pattern
    val patternName: String, // User-friendly name for the pattern
    val messageStructure: String, // Simplified structure for matching
    val amountPattern: String, // Regex or position for amount extraction
    val counterpartyPattern: String, // Regex or position for counterparty extraction
    val datePattern: String? = null, // Optional date extraction
    val referencePattern: String? = null, // Optional reference number extraction
    val transactionType: TransactionType, // CREDIT or DEBIT
    val isActive: Boolean = true, // Whether this pattern should be used
    val defaultCategoryID: String = "",
    val defaultAccountID: String = "",
    val autoSelectAccount: Boolean = false,
    val senderName: String = "",
    val createdTimestamp: Long = System.currentTimeMillis(),
    val lastUsedTimestamp: Long? = null
)