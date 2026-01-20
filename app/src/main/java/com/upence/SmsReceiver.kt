package com.upence

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.provider.Telephony
import android.util.Log
import com.upence.data.AppDatabase
import com.upence.data.SMS
import com.upence.data.SMSDao
import com.upence.data.SenderDao
import com.upence.data.TransactionDao
import com.upence.util.NotificationHelper
import com.upence.util.SMSUtils
import com.upence.data.UserStore
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch
import kotlinx.coroutines.flow.first
import android.app.PendingIntent
import android.content.ComponentName
import android.os.Build

class SmsReceiver : BroadcastReceiver() {

    override fun onReceive(context: Context, intent: Intent) {
        if (intent.action == Telephony.Sms.Intents.SMS_RECEIVED_ACTION) {
            Log.d("SmsReceiver", "SMS received, starting processing")
            
            val pendingResult = goAsync()
            
            CoroutineScope(Dispatchers.IO).launch {
                try {
                    val messages = Telephony.Sms.Intents.getMessagesFromIntent(intent)
                    if (messages.isNullOrEmpty()) {
                        Log.w("SmsReceiver", "No messages found in intent")
                        return@launch
                    }
                    
                    val database = AppDatabase.getDatabase(context)
                    val smsDao = database.SMSDao()
                    val senderDao = database.SenderDao()
                    val transactionDao = database.transactionDao()
                    val userStore = UserStore(context)
                    
                    for (message in messages) {
                        val body = message.messageBody ?: ""
                        val sender = message.originatingAddress ?: ""
                        val timestamp = message.timestampMillis

                        Log.d("SmsReceiver", "Processing SMS from $sender at $timestamp")

                        val senderEntity = senderDao.getSenderByName(sender)
                        if (senderEntity?.isIgnored == true) {
                            Log.d("SmsReceiver", "Ignored sender: $sender - skipping SMS")
                            continue
                        }

                        val isBankMessage = sender.endsWith("-S") || 
                                             sender.contains("BANK", ignoreCase = true) ||
                                             sender.contains("UPI", ignoreCase = true) ||
                                             sender.contains("TRANSACTION", ignoreCase = true)

                        if (!isBankMessage) {
                            Log.w("SmsReceiver", "Non-bank SMS ignored: $sender")
                            continue
                        }

                        val sms = SMS(
                            sender = sender,
                            message = body,
                            timestamp = timestamp
                        )

                        val newSmsId = smsDao.insertSMS(sms)

                        Log.d("SmsReceiver", "SMS inserted with ID: $newSmsId")

                        // Cache management: Keep only 50 most recent SMS
                        try {
                            val smsCount = smsDao.getSMSCount()
                            if (smsCount > 50) {
                                smsDao.deleteOldestSMS()
                                Log.d("SmsReceiver", "Deleted oldest SMS to maintain cache of 50")
                            }
                        } catch (e: Exception) {
                            Log.e("SmsReceiver", "Error managing SMS cache: ${e.message}")
                        }

                        try {
                            SMSUtils.parseTransactionFromSMS(context, sender, body)?.let { transaction ->
                                transactionDao.insertTransaction(transaction)
                                Log.i("SmsReceiver", "Auto-created transaction from SMS pattern")
                            }
                        } catch (e: Exception) {
                            Log.w("SmsReceiver", "Failed to auto-parse transaction: ${e.message}")
                        }

                        val currencySymbol = userStore.currencySymbol.first()

                        val launchIntent = Intent(context, MainActivity::class.java).apply {
                            flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TASK
                            putExtra("sms_id", newSmsId)
                            putExtra("from_background", true)
                            component = ComponentName(context.packageName, MainActivity::class.java.name)
                        }

                        val pendingIntentFlags = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                            PendingIntent.FLAG_IMMUTABLE or PendingIntent.FLAG_UPDATE_CURRENT
                        } else {
                            PendingIntent.FLAG_UPDATE_CURRENT
                        }

                        val pendingIntent = PendingIntent.getActivity(
                            context,
                            newSmsId.toInt(),
                            launchIntent,
                            pendingIntentFlags
                        )

                        NotificationHelper.sendSmsNotification(
                            context = context,
                            sender = sender,
                            messageBody = body,
                            smsId = newSmsId,
                            currencySymbol = currencySymbol,
                            pendingIntent = pendingIntent
                        )
                    }
                } catch (e: Exception) {
                    Log.e("SmsReceiver", "Error processing SMS: ${e.message}", e)
                } finally {
                    pendingResult.finish()
                    Log.d("SmsReceiver", "Processing completed")
                }
            }
        }
    }
}
