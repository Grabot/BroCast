package com.bro.brocast.notification

import android.content.Context
import com.bro.brocast.R
import com.google.firebase.messaging.FirebaseMessagingService
import com.google.firebase.messaging.RemoteMessage

class MessagingService : FirebaseMessagingService() {

    override fun onMessageReceived(remoteMessage: RemoteMessage) {
        if (remoteMessage.notification != null) {
            showNotification(remoteMessage.notification?.title!!, remoteMessage.notification?.body!!)
        }
    }

    private fun showNotification(title: String, body: String) {
        NotificationUtil.createNotification(
            this,
            title,
            body,
            false
        )
    }

    /**
     * Called if InstanceID token is updated. This may occur if the security of
     * the previous token had been compromised.
     * If you want to send messages to this application instance or manage this apps subscriptions
     * on the server side, send the Instance ID token to your app server.
     */
    override fun onNewToken(token: String) {
        val sharedPreferences = this.getSharedPreferences(this.getString(R.string.preference_file_key), Context.MODE_PRIVATE)
        val editor = sharedPreferences.edit()
        editor.putString("REGISTRATION_TOKEN", token)
        editor.apply()
    }
}