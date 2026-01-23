package com.upence.data

import android.content.Context
import androidx.room.Database
import androidx.room.Room
import androidx.room.RoomDatabase
import androidx.sqlite.db.SupportSQLiteDatabase
import androidx.room.migration.Migration
import androidx.room.TypeConverter
import androidx.room.TypeConverters

import java.time.Instant

@Database(entities = [Transaction::class, BankAccounts::class, Senders::class, Tags::class, TransactionTags::class, Categories::class, SMS::class, SMSParsingPattern::class], version = 8)
@TypeConverters(TransactionConverters::class, InstantConverters::class)
abstract class AppDatabase : RoomDatabase() {
    abstract fun transactionDao(): TransactionDao

    abstract fun BankAccountsDao(): BankAccountsDao

    abstract fun categoryDao(): CategoriesDao

    abstract fun SMSDao(): SMSDao

    abstract fun SenderDao(): SenderDao

    abstract fun SMSParsingPatternDao(): SMSParsingPatternDao

    abstract fun TagsDao(): com.upence.data.TagsDao

    companion object {
        @Volatile
        private var INSTANCE: AppDatabase? = null
        
        private val MIGRATION_3_4 = object : Migration(3, 4) {
            override fun migrate(database: SupportSQLiteDatabase) {
                // Add new columns to senders table
                database.execSQL(
                    "ALTER TABLE senders ADD COLUMN isIgnored INTEGER NOT NULL DEFAULT 0"
                )
                database.execSQL(
                    "ALTER TABLE senders ADD COLUMN ignoreReason TEXT"
                )
                database.execSQL(
                    "ALTER TABLE senders ADD COLUMN ignoredAt INTEGER"
                )
            }
        }

        private val MIGRATION_4_5 = object : Migration(4, 5) {
            override fun migrate(database: SupportSQLiteDatabase) {
                database.execSQL(
                    "ALTER TABLE sms_parsing_patterns ADD COLUMN defaultCategoryID TEXT NOT NULL DEFAULT ''"
                )
                database.execSQL(
                    "ALTER TABLE sms_parsing_patterns ADD COLUMN defaultAccountID TEXT NOT NULL DEFAULT ''"
                )
            }
        }

        private val MIGRATION_5_6 = object : Migration(5, 6) {
            override fun migrate(database: SupportSQLiteDatabase) {
                database.execSQL(
                    "ALTER TABLE sms ADD COLUMN processed INTEGER NOT NULL DEFAULT 0"
                )
            }
        }

        private val MIGRATION_6_7 = object : Migration(6, 7) {
            override fun migrate(database: SupportSQLiteDatabase) {
                database.execSQL(
                    "ALTER TABLE sms_parsing_patterns ADD COLUMN senderName TEXT DEFAULT ''"
                )
            }
        }

        fun getDatabase(context: Context): AppDatabase {
            return INSTANCE ?: synchronized(this) {
                Room.databaseBuilder(
                    context.applicationContext,
                    AppDatabase::class.java,
                    "upence_database"
                )
                    .addMigrations(MIGRATION_3_4, MIGRATION_4_5, MIGRATION_5_6, MIGRATION_6_7)
                    .fallbackToDestructiveMigration(true)
                    .build()
                    .also { INSTANCE = it }
            }
        }
    }
}

class TransactionConverters {
    @TypeConverter
    fun fromTransactionType(type: TransactionType): String {
        return type.name
    }

    @TypeConverter
    fun toTransactionType(value: String): TransactionType {
        return TransactionType.valueOf(value)
    }
}

class InstantConverters {
    @TypeConverter
    fun fromTimestamp(value: Long?): Instant? {
        return value?.let { Instant.ofEpochMilli(it) }
    }

    @TypeConverter
    fun instantToTimestamp(instant: Instant?): Long? {
        return instant?.toEpochMilli()
    }
}