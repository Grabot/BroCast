package com.bro.brocast.notification

import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.content.ContentResolver
import android.content.Context
import android.content.Intent
import android.media.AudioAttributes
import android.net.Uri
import android.os.Build
import androidx.core.app.NotificationCompat
import androidx.core.app.NotificationManagerCompat
import com.bro.brocast.BuildConfig
import com.bro.brocast.MainActivity
import com.bro.brocast.R


object NotificationUtil {

    val NOTIFICATION_SOUND_URI =
        Uri.parse(ContentResolver.SCHEME_ANDROID_RESOURCE + "://" + BuildConfig.APPLICATION_ID + "/" + R.raw.brodio)
    val VIBRATE_PATTERN = longArrayOf(0, 500)

    fun createNotificationChannel(context: Context, importance: Int, description: String) {
        // TODO @Skools: set the target sdk to minimal this in manifest.
        // check for the correct version
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            // create a unique name for the channel
            val channelId = context.getString(R.string.channel_id)
            val channelName = context.getString(R.string.channel_name)
            val channel = NotificationChannel(channelId, channelName, importance)
            channel.description = description
            // TODO @Skools: find out what the badge does
            channel.setShowBadge(false)

            val audioAttributes = AudioAttributes.Builder()
                .setContentType(AudioAttributes.CONTENT_TYPE_SONIFICATION)
                .setUsage(AudioAttributes.USAGE_NOTIFICATION_RINGTONE)
                .build()

            channel.setSound(NOTIFICATION_SOUND_URI, audioAttributes)
//            channel.lightColor = NOTIFICATION_COLOR
//            channel.vibrationPattern = VIBRATE_PATTERN
            channel.enableVibration(true)

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