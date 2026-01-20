package com.upence.data

import androidx.room.Dao
import androidx.room.Delete
import androidx.room.Insert
import androidx.room.OnConflictStrategy
import androidx.room.Query
import kotlinx.coroutines.flow.Flow


@Dao
interface CategoriesDao {
    @Query("SELECT * FROM categories")
    fun getAllCategories(): Flow<List<Categories>>

    @Insert(onConflict = OnConflictStrategy.REPLACE)
    suspend fun insertCategory(category: Categories)

    @Delete
    suspend fun deleteCategory(category: Categories)

    @Query("SELECT COUNT(*) FROM transactions WHERE categoryID = :categoryId")
    suspend fun getTransactionCount(categoryId: String): Int

    @Query("UPDATE transactions SET categoryID = :newCategoryId WHERE categoryID = :oldCategoryId")
    suspend fun migrateCategoryTransactions(oldCategoryId: String, newCategoryId: String)

    @Query("SELECT * FROM categories ORDER BY name ASC")
    fun getAllCategoriesSorted(): Flow<List<Categories>>
}