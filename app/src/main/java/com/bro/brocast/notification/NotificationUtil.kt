package com.bro.brocast.notification

import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.os.Build
import androidx.core.app.NotificationCompat
import androidx.core.app.NotificationManagerCompat
import com.bro.brocast.MainActivity
import com.bro.brocast.R

object NotificationUtil {
    fun createNotificationChannel(context: Context, importance: Int, name: String, description: String) {
        // TODO @Skools: set the target sdk to minimal this in manifest.
        // check for the correct version
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            // create a unique name for the channel
            val channelId = "${context.packageName}-$name"
            val channel = NotificationChannel(channelId, name, importance)
            channel.description = description
            // TODO @Skools: find out what the badge does
            channel.setShowBadge(false)

            // create the channel using NotificationManager
            val notificationManager = context.getSystemService(NotificationManager::class.java)
            notificationManager!!.createNotificationChannel(channel)
        }
    }

    fun createTestNotification(context: Context, title: String, message: String, bigText: String, autoCancel: Boolean) {
        val channelId = "${context.packageName}-${context.getString(R.string.app_name)}"
        val notificationBuilder = NotificationCompat.Builder(context, channelId).apply {
            // TODO @Skools: give it a better icon, or none at all.
            setSmallIcon(R.drawable.brocastmessage)
            setContentTitle(title)
            setContentText(message)
            setStyle(NotificationCompat.BigTextStyle().bigText(bigText))
            priority = NotificationCompat.PRIORITY_DEFAULT
            setAutoCancel(autoCancel)

            // When the user taps the notification he is directed to the mainactivity.
            val intent = Intent(context, MainActivity::class.java)
            intent.flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TASK
            val pendingIntent = PendingIntent.getActivity(context, 0, intent, 0)
            setContentIntent(pendingIntent)
        }

        val notificationManager = NotificationManagerCompat.from(context)
        notificationManager.notify(1001, notificationBuilder.build())
    }
}