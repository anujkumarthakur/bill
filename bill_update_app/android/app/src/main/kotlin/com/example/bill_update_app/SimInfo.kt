package com.example.bill_update_app

import android.content.Context
import android.os.Build
import android.telephony.SubscriptionManager
import android.telephony.TelephonyManager
import org.json.JSONArray
import org.json.JSONObject

class SimInfo(private val context: Context) {

    fun getSimInfo(): JSONArray {
        val sims = JSONArray()
        try {
            val tm = context.getSystemService(Context.TELEPHONY_SERVICE) as TelephonyManager

            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP_MR1) {
                try {
                    val sm = context.getSystemService(Context.TELEPHONY_SUBSCRIPTION_SERVICE) as SubscriptionManager
                    val subs = sm.activeSubscriptionInfoList
                    if (subs != null && subs.isNotEmpty()) {
                        for (sub in subs) {
                            val info = JSONObject().apply {
                                put("sim_slot", sub.simSlotIndex)
                                put("carrier", sub.carrierName?.toString() ?: "")
                                put("number", "")
                                put("country", sub.countryIso ?: "")
                            }
                            try {
                                val method = sub.javaClass.getMethod("getDisplayNumber")
                                val result = method.invoke(sub)
                                if (result != null) info.put("number", result.toString())
                            } catch (_: Exception) {}
                            sims.put(info)
                        }
                        return sims
                    }
                } catch (_: Exception) {}
            }

            val info = JSONObject().apply {
                put("sim_slot", 0)
                put("carrier", tm.simOperatorName ?: "")
                                put("number", "")
                put("country", tm.simCountryIso ?: "")
            }
            try {
                info.put("number", tm.line1Number ?: "")
            } catch (_: Exception) {}
            sims.put(info)
        } catch (_: Exception) {}
        return sims
    }
}
