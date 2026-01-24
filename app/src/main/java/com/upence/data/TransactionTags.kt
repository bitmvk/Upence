package com.upence.data

import androidx.room.Entity
import androidx.room.ForeignKey
import androidx.room.PrimaryKey

@Entity(
    tableName = "transactionTags",
    foreignKeys = [
        ForeignKey(Tags::class, parentColumns = ["id"], childColumns = ["tagID"]),
        ForeignKey(Transaction::class, parentColumns = ["id"], childColumns = ["transactionID"]),
    ],
)
data class TransactionTags(
    @PrimaryKey(autoGenerate = true)
    val id: Int,
    val tagID: String,
    val transactionID: String,
)
