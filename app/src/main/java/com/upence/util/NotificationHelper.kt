package com.upence.util

import android.Manifest
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.content.pm.PackageManager
import android.os.Build
import android.util.Log
import androidx.core.app.ActivityCompat
import androidx.core.app.NotificationCompat
import androidx.core.app.NotificationManagerCompat
import com.upence.MainActivity
import com.upence.NotificationActionReceiver
import com.upence.R
import java.util.Locale

object NotificationHelper {
    private const val SMS_CHANNEL_ID = "upence_sms_channel"
    private const val SMS_CHANNEL_NAME = "Transaction Alerts"
    private const val SMS_CHANNEL_DESC = "Notifications for SMS transactions"

    fun sendSmsNotification(
        context: Context,
        sender: String,
        messageBody: String,
        smsId: Long,
        currencySymbol: String = "₹",
        pendingIntent: PendingIntent? = null
    ) {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU &&
            ActivityCompat.checkSelfPermission(context, Manifest.permission.POST_NOTIFICATIONS) != PackageManager.PERMISSION_GRANTED
        ) {
            Log.w("NotificationHelper", "Notification permission not granted")
            return
        }
        
        createSmsNotificationChannel(context)
        
        // Clean sender name for display
        val displaySender = sender.take(30).replace("-S", "")
        
        val builder = NotificationCompat.Builder(context, SMS_CHANNEL_ID)
            .setSmallIcon(R.drawable.ic_notification)
            .setContentTitle("Transaction from $displaySender")
        
        // Try to extract amount for more informative notification
        val amountMatch = Regex("""\b(?:Rs\.?|₹|INR)?\s*([\d,]+\.?\d*)\b""").find(messageBody)
        val amountText = amountMatch?.groups?.get(1)?.value?.let { amount ->
            try {
                val cleanAmount = amount.replace(",", "").toDoubleOrNull()
                cleanAmount?.let { "$currencySymbol${String.format(Locale.US, "%.2f", it)}" }
            } catch (e: Exception) {
                null
            }
        }
        
        val contentText = if (amountText != null) {
            "Amount: $amountText • Tap to process"
        } else {
            "Tap to process"
        }
        
        builder.setContentText(contentText)
            .setStyle(NotificationCompat.BigTextStyle()
                .bigText("$messageBody\n\nTap to categorize and save."))
            .setPriority(NotificationCompat.PRIORITY_HIGH)
            .setContentIntent(pendingIntent)
            .setAutoCancel(true)
            .setCategory(NotificationCompat.CATEGORY_REMINDER)
            .setColor(context.getColor(R.color.purple_500))
            .setVisibility(NotificationCompat.VISIBILITY_PUBLIC)
            .setTimeoutAfter(60000)
            .setShowWhen(true)

        val pendingIntentFlags = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            PendingIntent.FLAG_IMMUTABLE or PendingIntent.FLAG_UPDATE_CURRENT
        } else {
            PendingIntent.FLAG_UPDATE_CURRENT
        }

        // Action: Not this SMS (delete only this SMS)
        val notThisSMSIntent = Intent(context, NotificationActionReceiver::class.java).also {
            it.action = NotificationActionReceiver.ACTION_NOT_THIS_SMS
            it.putExtra("sms_id", smsId)
        }
        val notThisSMPendingIntent = PendingIntent.getBroadcast(
            context,
            smsId.toInt() + 1000,
            notThisSMSIntent,
            pendingIntentFlags
        )

        // Action: Ignore Sender (mark sender as ignored and delete SMS)
        val ignoreSenderIntent = Intent(context, NotificationActionReceiver::class.java).also {
            it.action = NotificationActionReceiver.ACTION_NOT_TRANSACTION
            it.putExtra("sms_id", smsId)
            it.putExtra("sender", sender)
        }
        val ignoreSenderPendingIntent = PendingIntent.getBroadcast(
            context,
            smsId.toInt() + 2000,
            ignoreSenderIntent,
            pendingIntentFlags
        )

        builder.addAction(
            R.drawable.ic_notification,
            "Not This SMS",
            notThisSMPendingIntent
        )
        builder.addAction(
            R.drawable.ic_notification,
            "Ignore Sender",
            ignoreSenderPendingIntent
        )
        
        try {
            NotificationManagerCompat.from(context).notify(smsId.toInt(), builder.build())
            Log.d("NotificationHelper", "Notification sent successfully with ID: $smsId")
        } catch (e: SecurityException) {
            Log.e("NotificationHelper", "Security exception sending notification: ${e.message}")
        } catch (e: Exception) {
            Log.e("NotificationHelper", "Error sending notification: ${e.message}")
        }
    }

    fun createSmsNotificationChannel(context: Context) {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val channel = NotificationChannel(
                SMS_CHANNEL_ID,
                SMS_CHANNEL_NAME,
                NotificationManager.IMPORTANCE_HIGH
            ).apply {
                description = SMS_CHANNEL_DESC
                enableLights(true)
                enableVibration(true)
                setShowBadge(true)
                lockscreenVisibility = NotificationCompat.VISIBILITY_PUBLIC
            }
            
            val notificationManager = context.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
            notificationManager.createNotificationChannel(channel)
        }
    }
}
