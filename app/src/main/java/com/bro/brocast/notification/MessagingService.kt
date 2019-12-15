package com.bro.brocast.notification

import com.google.firebase.messaging.FirebaseMessagingService
import com.google.firebase.messaging.RemoteMessage

class MessagingService : FirebaseMessagingService() {

    override fun onMessageReceived(remoteMessage: RemoteMessage) {
        // TODO(developer): Handle FCM messages here.
        // Not getting messages here? See why this may be: https://goo.gl/39bRNJ
        println("From: " + remoteMessage.from)
        // Check if message contains a data payload.
        // TODO @Sander: We only use notifications, so possibly remove this part.
        if (remoteMessage.data.size > 0) {
            println("Message data payload: " + remoteMessage.data)
            if ( /* Check if data needs to be processed by long running job */true) { // For long-running tasks (10 seconds or more) use Firebase Job Dispatcher.
                println("schedule job")
//                scheduleJob()
            } else { // Handle message within 10 seconds
                println("handle now")
//                handleNow()
            }
        }
        // Check if message contains a notification payload.
        if (remoteMessage.notification != null) {
            println("Message notificiation body: " + remoteMessage.notification!!.body)
            showNotification(remoteMessage.notification?.title, remoteMessage.notification?.body)
        }
        // Also if you intend on generating your own notifications as a result of a received FCM
        // message, here is where that should be initiated. See sendNotification method below.
    }

    private fun showNotification(title: String?, body: String?) {
        println("show notification")
    }

    /**
     * Called if InstanceID token is updated. This may occur if the security of
     * the previous token had been compromised. Note that this is called when the InstanceID token
     * is initially generated so this is where you would retrieve the token.
     */
    override fun onNewToken(token: String) {
        println("Refresed token: $token")
        // If you want to send messages to this application instance or
        // manage this apps subscriptions on the server side, send the
        // Instance ID token to your app server.
        println("send registration")
        // TODO @Sander: Here you should send the token to your database. This token can be used to
        //  determine the correct user. Since the user is not created when the app is opened you
        //  should store the token first and send it allong with the user registration. Since the
        //  user can close the app before first creating it's account you should store the token in
        //  sharedpreferences.
//        sendRegistrationToServer(token)
    }
}