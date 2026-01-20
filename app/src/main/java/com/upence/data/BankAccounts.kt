package com.upence.data

import androidx.room.Entity
import androidx.room.PrimaryKey

@Entity(tableName = "bankAccounts")
data class BankAccounts(
    @PrimaryKey(autoGenerate = true)
    val id: Int = 0,
    val accountName: String,
    val accountNumber: String,
    val description: String,
)
