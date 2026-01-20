package com.upence.data

import androidx.room.Entity
import androidx.room.PrimaryKey

@Entity()
data class Categories(
    @PrimaryKey(autoGenerate = true)
    val id: Int,
    val icon: String,
    val name: String,
    val color: Long,
    val description: String,
)
