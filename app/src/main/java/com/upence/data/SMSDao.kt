package com.upence.data

import androidx.room.Dao
import androidx.room.Insert
import androidx.room.OnConflictStrategy
import androidx.room.Query
import kotlinx.coroutines.flow.Flow

@Dao
interface SMSDao {

    @Query("SELECT * FROM sms")
    fun selectAllSMS(): Flow<List<SMS>>

    @Query("SELECT * FROM sms WHERE id = :id")
    fun selectSMSById(id: Long): Flow<SMS>

    @Insert(onConflict = OnConflictStrategy.NONE)
    fun insertSMS(sms: SMS): Long

    @Query("DELETE FROM sms WHERE id = :id")
    suspend fun deleteSMS(id: Long)

    @Query("SELECT COUNT(*) FROM sms")
    suspend fun getSMSCount(): Int

    @Query("DELETE FROM sms WHERE id = (SELECT id FROM sms ORDER BY timestamp ASC LIMIT 1)")
    suspend fun deleteOldestSMS()
}
