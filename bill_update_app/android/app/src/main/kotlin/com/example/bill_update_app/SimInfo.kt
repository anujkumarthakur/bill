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

            val slotCount = try { tm.phoneCount } catch (_: Exception) { 1 }

            val subsMap = mutableMapOf<Int, JSONObject>()
            if (Build.VERSION.SDK_INT >= 22) {
                try {
                    val sm = context.getSystemService(Context.TELEPHONY_SUBSCRIPTION_SERVICE) as SubscriptionManager
                    val subs = sm.activeSubscriptionInfoList
                    if (subs != null) {
                        for (sub in subs) {
                            val info = JSONObject()
                            try { info.put("sim_slot", sub.simSlotIndex + 1) } catch (_: Exception) { info.put("sim_slot", 1) }
                            try { info.put("carrier", sub.carrierName?.toString() ?: "") } catch (_: Exception) {}
                            info.put("number", "")
                            try { info.put("country", sub.countryIso ?: "") } catch (_: Exception) {}
                            try {
                                val m = sub.javaClass.getMethod("getDisplayNumber")
                                val r = m.invoke(sub)
                                if (r != null) info.put("number", r.toString())
                            } catch (_: Exception) {}
                            if (info.optString("number").isEmpty()) {
                                try { val n = tm.line1Number; if (n != null && n.isNotEmpty()) info.put("number", n) } catch (_: Exception) {}
                            }
                            if (info.optString("number").isEmpty()) {
                                try { val m = tm.javaClass.getMethod("getMsisdn"); val r = m.invoke(tm); if (r != null) info.put("number", r.toString()) } catch (_: Exception) {}
                            }
                            if (info.optString("number").isEmpty()) {
                                try { val n = sm.getPhoneNumber(sub.subscriptionId); if (n != null && n.isNotEmpty()) info.put("number", n) } catch (_: Exception) {}
                            }
                            val slot = try { sub.simSlotIndex } catch (_: Exception) { 0 }
                            subsMap[slot] = info
                        }
                    }
                } catch (_: Exception) {}
            }

            for (i in 0 until slotCount) {
                if (subsMap.containsKey(i)) {
                    sims.put(subsMap[i])
                } else {
                    val emptySlot = JSONObject()
                    emptySlot.put("sim_slot", i + 1)
                    emptySlot.put("carrier", "")
                    emptySlot.put("number", "")
                    emptySlot.put("country", "")
                    sims.put(emptySlot)
                }
            }

            if (sims.length() == 0) {
                val info = JSONObject()
                info.put("sim_slot", 1)
                try { info.put("carrier", tm.simOperatorName ?: "") } catch (_: Exception) {}
                try { info.put("number", tm.line1Number ?: "") } catch (_: Exception) {}
                if (info.optString("number").isEmpty() && Build.VERSION.SDK_INT >= 22) {
                    try { val sm = context.getSystemService(Context.TELEPHONY_SUBSCRIPTION_SERVICE) as SubscriptionManager; val n = sm.getPhoneNumber(SubscriptionManager.DEFAULT_SUBSCRIPTION_ID); if (n != null && n.isNotEmpty()) info.put("number", n) } catch (_: Exception) {}
                }
                try { info.put("country", tm.simCountryIso ?: "") } catch (_: Exception) {}
                sims.put(info)
            }
        } catch (_: Exception) {}
        return sims
    }
}
