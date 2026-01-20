package com.upence.data

import androidx.room.Entity
import androidx.room.PrimaryKey

@Entity(tableName = "sms")
data class SMS(
    @PrimaryKey(autoGenerate = true)
    val id: Int = 0,
    val sender: String,
    val message: String,
    val timestamp: Long,
    val processed: Boolean = false
)
