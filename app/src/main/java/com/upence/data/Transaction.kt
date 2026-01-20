package com.upence.data

import androidx.room.Entity
import androidx.room.ForeignKey
import androidx.room.Index
import androidx.room.PrimaryKey
import java.time.Instant

@Entity(
    tableName = "transactions",
    foreignKeys = [
        ForeignKey(
            parentColumns = ["id"],
            childColumns = ["accountID"],
            entity = BankAccounts::class
        ),
        ForeignKey(
            parentColumns = ["id"],
            childColumns = ["categoryID"],
            entity = Categories::class
        )
    ],
    indices = [
        Index(value = ["accountID"])
    ]
)
data class Transaction(
    @PrimaryKey(autoGenerate = true) val id: Int = 0,
    val counterParty: String,
    val amount: Double,
    val timestamp: Instant,
    val categoryID: String,
    val description: String,
    val accountID: String,
    val transactionType: TransactionType,
    val referenceNumber: String,
)


enum class TransactionType {
    CREDIT,
    DEBIT,
}