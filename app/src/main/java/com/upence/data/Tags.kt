package com.upence.data

import androidx.room.Entity
import androidx.room.PrimaryKey

@Entity(tableName = "tags")
data class Tags(
    @PrimaryKey(autoGenerate = true)
    val id: Int,
    val name: String,
    val color: String,
)
