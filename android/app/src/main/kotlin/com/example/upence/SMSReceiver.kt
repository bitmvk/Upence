package com.example.upence

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.os.Bundle
import android.telephony.SmsMessage
import io.flutter.plugin.common.MethodChannel

class SMSReceiver : BroadcastReceiver() {
    companion object {
        private const val CHANNEL = "com.example.upence/sms"
        private var methodChannel: MethodChannel? = null

        fun setMethodChannel(channel: MethodChannel) {
            methodChannel = channel
        }
    }

    override fun onReceive(context: Context?, intent: Intent?) {
        if (intent?.action == "android.provider.Telephony.SMS_RECEIVED") {
            val bundle = intent?.extras
            if (bundle != null) {
                val pdus = bundle.get("pdus") as Array<*>?
                pdus?.forEach {
                    val smsMessage = SmsMessage.createFromPdu(it as ByteArray)
                    val sender = smsMessage.originatingAddress
                    val messageBody = smsMessage.messageBody
                    val timestamp = smsMessage.timestampMillis

                    val smsData = mapOf(
                        "sender" to sender,
                        "message" to messageBody,
                        "timestamp" to timestamp
                    )

                    methodChannel?.invokeMethod("onSMSReceived", smsData)
                }
            }
        }
    }
}
