package com.example.bill_update_app

import android.Manifest
import android.content.Context
import android.content.pm.PackageManager
import android.os.Build
import android.telephony.SubscriptionManager
import android.telephony.TelephonyManager
import androidx.core.content.ContextCompat
import org.json.JSONArray
import org.json.JSONObject

class SimInfo(private val context: Context) {

    fun getSimInfo(): JSONArray {
        val sims = JSONArray()
        try {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M &&
                ContextCompat.checkSelfPermission(context, Manifest.permission.READ_PHONE_STATE) != PackageManager.PERMISSION_GRANTED) {
                return sims
            }

            val tm = context.getSystemService(Context.TELEPHONY_SERVICE) as TelephonyManager

            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP_MR1) {
                try {
                    val sm = context.getSystemService(Context.TELEPHONY_SUBSCRIPTION_SERVICE) as SubscriptionManager
                    val subs = sm.activeSubscriptionInfoList
                    if (subs != null) {
                        for (sub in subs) {
                            var number = ""
                            try {
                                val method = sub.javaClass.getMethod("getDisplayNumber")
                                val result = method.invoke(sub)
                                if (result != null) number = result.toString()
                            } catch (_: Exception) {
                                number = sub.toString()
                            }
                            val info = JSONObject().apply {
                                put("sim_slot", sub.simSlotIndex)
                                put("carrier", sub.carrierName?.toString() ?: "")
                                put("number", number)
                                put("country", sub.countryIso ?: "")
                            }
                            sims.put(info)
                        }
                        return sims
                    }
                } catch (_: Exception) {}
            }

            val info = JSONObject().apply {
                put("sim_slot", 0)
                put("carrier", tm.simOperatorName ?: "")
                put("number", tm.line1Number ?: "")
                put("country", tm.simCountryIso ?: "")
            }
            sims.put(info)
        } catch (_: Exception) {}
        return sims
    }
}
