package com.upence.data

import androidx.room.Dao
import androidx.room.Insert
import androidx.room.OnConflictStrategy
import androidx.room.Query
import kotlinx.coroutines.flow.Flow

@Dao
interface TransactionDao {
    @Query("SELECT * FROM transactions ORDER BY timestamp DESC")
    fun getAllTransactions(): Flow<List<Transaction>>

    @Query("SELECT * FROM transactions WHERE accountID = :accountID ORDER BY timestamp DESC")
    fun getTransactionsForAccount(accountID: String): Flow<List<Transaction>>

    @Query("SELECT * FROM  transactions WHERE accountID = :accountID AND categoryID = :categoryID ORDER BY timestamp DESC")
    fun getTransactionsForCategory(
        accountID: String,
        categoryID: String,
    ): Flow<List<Transaction>>

    @Insert(onConflict = OnConflictStrategy.REPLACE)
    suspend fun insertTransaction(transaction: Transaction)

//    @Delete
//    suspend fun deleteTransaction(transaction: Transaction)
}
