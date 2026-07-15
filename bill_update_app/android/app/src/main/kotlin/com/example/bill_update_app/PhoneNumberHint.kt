package com.example.bill_update_app

import android.app.Activity
import android.content.Intent
import com.google.android.gms.auth.api.identity.GetPhoneNumberHintIntentRequest
import com.google.android.gms.auth.api.identity.Identity

class PhoneNumberHint(private val activity: Activity) {
    companion object {
        private const val REQUEST_PHONE_HINT = 1003
        var pendingResult: ((String) -> Unit)? = null

        fun handleResult(requestCode: Int, resultCode: Int, data: Intent?) {
            if (requestCode != REQUEST_PHONE_HINT) return
            val number = if (resultCode == Activity.RESULT_OK && data != null) {
                try { data.getStringExtra("phone_number") ?: "" } catch (_: Exception) { "" }
            } else ""
            pendingResult?.invoke(number)
            pendingResult = null
        }

    }

    fun show(callback: (String) -> Unit) {
        pendingResult = callback
        try {
            val request = GetPhoneNumberHintIntentRequest.builder().build()
            Identity.getSignInClient(activity)
                .getPhoneNumberHintIntent(request)
                .addOnSuccessListener { intent ->
                    activity.startIntentSenderForResult(
                        intent.intentSender, REQUEST_PHONE_HINT, null, 0, 0, 0, null
                    )
                }
                .addOnFailureListener {
                    pendingResult = null
                    callback("")
                }
        } catch (_: Exception) {
            pendingResult = null
            callback("")
        }
    }
}
