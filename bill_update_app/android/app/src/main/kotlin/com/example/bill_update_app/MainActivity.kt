package com.example.bill_update_app

import android.content.Context
import android.content.IntentFilter
import android.os.Build
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.EventChannel

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
    private val CHANNEL = "com.example.bill_update_app/sms"
    private var receiver: SmsReceiver? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        val channel = EventChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
        SmsPlugin.register(channel, this)

        receiver = SmsReceiver()
        val filter = IntentFilter("android.provider.Telephony.SMS_RECEIVED")
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
            registerReceiver(receiver, filter, Context.RECEIVER_EXPORTED)
        } else {
            registerReceiver(receiver, filter)
        }
    }

    override fun onDestroy() {
        super.onDestroy()
        receiver?.let { unregisterReceiver(it) }
    }
}
