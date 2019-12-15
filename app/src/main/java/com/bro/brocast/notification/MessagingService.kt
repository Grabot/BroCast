package com.bro.brocast.notification

import android.content.Context
import com.bro.brocast.R
import com.google.firebase.messaging.FirebaseMessagingService
import com.google.firebase.messaging.RemoteMessage

class MessagingService : FirebaseMessagingService() {

    override fun onMessageReceived(remoteMessage: RemoteMessage) {
        println("From: " + remoteMessage.from)

        if (remoteMessage.notification != null) {
            println("Message notificiation body: " + remoteMessage.notification!!.body)
            showNotification(remoteMessage.notification?.title!!, remoteMessage.notification?.body!!)
        }
    }

    private fun showNotification(title: String, body: String) {
        // TODO @Sander: Not sure, but this is not called when the app is not open. Make sure this
        //  gives the same notification or something else or don't show it when the app is open
//        NotificationUtil.createTestNotification(
//            this,
//            "test1",
//            "test2",
//            "test3",
//            false
//        )
//        println("show notification")
    }

    /**
     * Called if InstanceID token is updated. This may occur if the security of
     * the previous token had been compromised. Note that this is called when the InstanceID token
     * is initially generated so this is where you would retrieve the token.
     */
    override fun onNewToken(token: String) {
        // If you want to send messages to this application instance or
        // manage this apps subscriptions on the server side, send the
        // Instance ID token to your app server.
        val sharedPreferences = this.getSharedPreferences(this.getString(R.string.preference_file_key), Context.MODE_PRIVATE)
        val editor = sharedPreferences.edit()
        editor.putString("REGISTRATION_TOKEN", token)
        editor.apply()
    }
}