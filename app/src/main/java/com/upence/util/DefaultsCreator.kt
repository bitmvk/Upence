package com.upence.util

import com.upence.data.*

suspend fun createDefaultCategories(categoryDao: CategoriesDao) {
    val defaults = listOf(
        Categories(
            id = 0,
            icon = "🍔",
            name = "Food and Groceries",
            color = 0xFFF54284,
            description = ""
        ),
        Categories(
            id = 1,
            icon = "🚂",
            name = "Travel",
            color = 0xFF4AC998,
            description = ""
        ),
        Categories(
            id = 2,
            icon = "👤",
            name = "To People",
            color = 0xFF4D9DE0,
            description = ""
        ),
        Categories(
            id = 3,
            icon = "🚗",
            name = "Tolls",
            color = 0xFF8F78FA,
            description = ""
        ),
        Categories(
            id = 4,
            icon = "🛒",
            name = "Online Shopping",
            color = 0xFF9D4EDD,
            description = ""
        ),
        Categories(
            id = 5,
            icon = "💡",
            name = "Bills and Utilities",
            color = 0xFFFF9E45,
            description = ""
        )
    )
    defaults.forEach { categoryDao.insertCategory(it) }
}

suspend fun createDefaultAccounts(bankAccountsDao: BankAccountsDao) {
    // Accounts are user-defined, no defaults
    // This function can be used for initial setup if needed
}
