package com.upence

import android.app.NotificationManager
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.util.Log
import com.upence.data.AppDatabase
import com.upence.data.SMSDao
import com.upence.data.SenderDao
import com.upence.data.Senders
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch

class NotificationActionReceiver : BroadcastReceiver() {
    companion object {
        const val ACTION_ADD_TRANSACTION = "com.upence.ADD_TRANSACTION"
        const val ACTION_NOT_TRANSACTION = "com.upence.NOT_TRANSACTION"
        const val ACTION_NOT_THIS_SMS = "com.upence.NOT_THIS_SMS"
    }

    override fun onReceive(
        context: Context,
        intent: Intent,
    ) {
        when (intent.action) {
            ACTION_ADD_TRANSACTION -> {
                val smsId = intent.getLongExtra("sms_id", -1)
                Log.d("NotificationActionReceiver", "Add Transaction action triggered for SMS ID: $smsId")

                // This action just needs to navigate - MainActivity will handle the navigation
                // The notification should have been created with proper intent
            }

            ACTION_NOT_THIS_SMS -> {
                val smsId = intent.getLongExtra("sms_id", -1)
                Log.d("NotificationActionReceiver", "Not This SMS action triggered for ID: $smsId")

                CoroutineScope(Dispatchers.IO).launch {
                    try {
                        val database = AppDatabase.getDatabase(context)
                        val smsDao = database.SMSDao()
                        smsDao.deleteSMS(smsId)

                        val notificationManager = context.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
                        notificationManager.cancel(smsId.hashCode())

                        Log.d("NotificationActionReceiver", "SMS $smsId deleted")
                    } catch (e: Exception) {
                        Log.e("NotificationActionReceiver", "Error handling not this SMS: ${e.message}", e)
                    }
                }
            }

            ACTION_NOT_TRANSACTION -> {
                val smsId = intent.getLongExtra("sms_id", -1)
                val sender = intent.getStringExtra("sender")

                if (sender != null) {
                    Log.d("NotificationActionReceiver", "Not a Transaction action triggered for sender: $sender")

                    CoroutineScope(Dispatchers.IO).launch {
                        try {
                            val database = AppDatabase.getDatabase(context)
                            val senderDao = database.SenderDao()
                            val smsDao = database.SMSDao()

                            // Mark sender as ignored
                            val existingSender = senderDao.getSenderByName(sender)
                            if (existingSender != null) {
                                senderDao.markSenderAsIgnored(
                                    senderName = sender,
                                    reason = "Not a transaction",
                                )
                            } else {
                                // Create new sender entry as ignored
                                senderDao.insertSender(
                                    Senders(
                                        id = sender.hashCode(),
                                        senderName = sender,
                                        accountID = "",
                                        description = "",
                                        isIgnored = true,
                                        ignoreReason = "Not a transaction",
                                        ignoredAt = System.currentTimeMillis(),
                                    ),
                                )
                            }

                            // Delete the SMS
                            smsDao.deleteSMS(smsId)

                            // Cancel notification
                            val notificationManager = context.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
                            notificationManager.cancel(smsId.hashCode())

                            Log.d("NotificationActionReceiver", "Sender $sender marked as ignored and SMS $smsId deleted")
                        } catch (e: Exception) {
                            Log.e("NotificationActionReceiver", "Error handling not a transaction: ${e.message}", e)
                        }
                    }
                }
            }
        }
    }
}
