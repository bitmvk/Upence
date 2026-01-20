package com.upence.data

import androidx.room.Dao
import androidx.room.Insert
import androidx.room.Query
import androidx.room.Update
import kotlinx.coroutines.flow.Flow

@Dao
interface SMSParsingPatternDao {
    
    @Insert
    suspend fun insertPattern(pattern: SMSParsingPattern): Long
    
    @Update
    suspend fun updatePattern(pattern: SMSParsingPattern)
    
    @Query("SELECT * FROM sms_parsing_patterns WHERE id = :patternId")
    fun getPatternById(patternId: Int): Flow<SMSParsingPattern?>
    
    @Query("SELECT * FROM sms_parsing_patterns WHERE senderIdentifier LIKE :senderPattern AND isActive = 1 ORDER BY lastUsedTimestamp DESC")
    fun getPatternsBySender(senderPattern: String): Flow<List<SMSParsingPattern>>
    
    @Query("SELECT * FROM sms_parsing_patterns WHERE isActive = 1 ORDER BY lastUsedTimestamp DESC")
    fun getAllActivePatterns(): Flow<List<SMSParsingPattern>>
    
    @Query("UPDATE sms_parsing_patterns SET lastUsedTimestamp = :timestamp WHERE id = :patternId")
    suspend fun updateLastUsedTimestamp(patternId: Int, timestamp: Long)
    
    @Query("UPDATE sms_parsing_patterns SET isActive = :isActive WHERE id = :patternId")
    suspend fun setPatternActive(patternId: Int, isActive: Boolean)
    
    @Query("DELETE FROM sms_parsing_patterns WHERE id = :patternId")
    suspend fun deletePattern(patternId: Int)
    
    // Find similar patterns based on message structure
    @Query("""
        SELECT * FROM sms_parsing_patterns 
        WHERE isActive = 1 
        AND (senderIdentifier LIKE :senderPattern OR :senderPattern LIKE senderIdentifier)
        ORDER BY 
            CASE WHEN senderIdentifier = :senderPattern THEN 1 ELSE 0 END DESC,
            lastUsedTimestamp DESC
    """)
    suspend fun findSimilarPatterns(senderPattern: String): List<SMSParsingPattern>
    
    @Query("SELECT * FROM sms_parsing_patterns WHERE isActive = 1 AND senderIdentifier = :sender")
    suspend fun getActivePatternsForSender(sender: String): List<SMSParsingPattern>

    @Query("UPDATE sms_parsing_patterns SET defaultCategoryID = :categoryID, defaultAccountID = :accountID WHERE id = :patternId")
    suspend fun updateDefaults(patternId: Int, categoryID: String, accountID: String)
}