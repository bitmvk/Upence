package com.upence.data

import androidx.room.Dao
import androidx.room.Insert
import androidx.room.OnConflictStrategy
import androidx.room.Query
import kotlinx.coroutines.flow.Flow


@Dao
interface SenderDao {
    @Query("SELECT * FROM senders WHERE accountID = :accountID ORDER BY senderName DESC")
    fun getSendersForAccount(accountID: String): Flow<List<Senders>>

    @Insert(onConflict = OnConflictStrategy.REPLACE)
    fun insertSender(senders: Senders)

    @Query("SELECT * FROM senders WHERE senderName = :senderName LIMIT 1")
    suspend fun getSenderByName(senderName: String): Senders?

    @Query("SELECT * FROM senders WHERE isIgnored = 1 ORDER BY senderName")
    fun getIgnoredSenders(): Flow<List<Senders>>

    @Query("UPDATE senders SET isIgnored = 1, ignoreReason = :reason, ignoredAt = :timestamp WHERE senderName = :senderName")
    suspend fun markSenderAsIgnored(senderName: String, reason: String, timestamp: Long = System.currentTimeMillis())

    @Query("UPDATE senders SET isIgnored = 0, ignoreReason = NULL, ignoredAt = NULL WHERE senderName = :senderName")
    suspend fun unmarkSenderAsIgnored(senderName: String)

    @Query("DELETE FROM senders WHERE senderName = :senderName")
    suspend fun deleteSenderByName(senderName: String)
}