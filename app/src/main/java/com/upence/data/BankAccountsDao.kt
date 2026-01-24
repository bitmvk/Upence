package com.upence.data

import androidx.room.Dao
import androidx.room.Delete
import androidx.room.Insert
import androidx.room.OnConflictStrategy
import androidx.room.Query
import kotlinx.coroutines.flow.Flow

@Dao
interface BankAccountsDao {
    @Query("SELECT * FROM bankAccounts ORDER BY accountNumber DESC")
    fun getAllAccounts(): Flow<List<BankAccounts>>

    @Insert(onConflict = OnConflictStrategy.REPLACE)
    suspend fun insertBankAccount(bankAccount: BankAccounts)

    @Delete
    suspend fun deleteBankAccount(bankAccount: BankAccounts)

    @Query("SELECT COUNT(*) FROM transactions WHERE accountID = :accountId")
    suspend fun getTransactionCount(accountId: String): Int

    @Query("UPDATE transactions SET accountID = :newAccountId WHERE accountID = :oldAccountId")
    suspend fun migrateAccountTransactions(
        oldAccountId: String,
        newAccountId: String,
    )

    @Query("SELECT * FROM bankAccounts ORDER BY accountName ASC")
    fun getAllAccountsSorted(): Flow<List<BankAccounts>>
}
