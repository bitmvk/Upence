package com.upence.data

import androidx.compose.ui.input.pointer.PointerId
import androidx.room.Entity
import androidx.room.ForeignKey
import androidx.room.PrimaryKey

@Entity(
    tableName = "senders", foreignKeys = [
        ForeignKey(
            entity = BankAccounts::class,
            parentColumns = ["id"],
            childColumns = ["accountID"],
            onDelete = ForeignKey.CASCADE
        )
    ]
)
data class Senders(
    @PrimaryKey(autoGenerate = false)
    val id: Int,
    val senderName: String,
    val accountID: String,
    val description: String,
    val isIgnored: Boolean = false,
    val ignoreReason: String? = null,
    val ignoredAt: Long? = null
)
