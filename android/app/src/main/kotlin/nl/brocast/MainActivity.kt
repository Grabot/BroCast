package nl.brocast

import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.NotificationChannelGroup
import android.content.ContentResolver
import android.graphics.Paint
import android.media.AudioAttributes
import android.net.Uri
import android.os.Build
import androidx.annotation.NonNull
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel


class MainActivity: FlutterActivity() {
    private val CHANNEL_EMOJI = "nl.brocast.emoji/available"
    private val CHANNEL_NOTIFICATION = "nl.brocast/channel_bro"

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL_EMOJI).setMethodCallHandler { call, result ->
            if (call.method.equals("isAvailable")) {
                val paint = Paint()
                val emojisAvailable: List<String>? = call.argument<List<String>>("emojis")
                val available: MutableList<String> = mutableListOf()
                for (item: String in emojisAvailable!!) {
                    if (paint.hasGlyph(item)) {
                        available.add(item)
                    }
                }
                result.success(available)
            }
        }

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL_NOTIFICATION).setMethodCallHandler {
            // Note: this method is invoked on the main thread.
            call, result ->

            if (call.method == "createNotificationChannel"){
                val argData = call.arguments as java.util.HashMap<String, String>
                val completed = createNotificationChannel(argData)
                if (completed == true){
                    result.success(completed)
                }
                else{
                    result.error("Error Code", "Error Message", null)
                }
            } else {
                result.notImplemented()
            }
        }
    }

    private fun createNotificationChannel(mapData: HashMap<String,String>): Boolean {
        val completed: Boolean
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {

            val notificationManager = getSystemService(NOTIFICATION_SERVICE) as NotificationManager

            val groupId = "custom_sound_brouping"
            val name = mapData["name"]

            var channelGroup = NotificationChannelGroup(groupId, name);
            notificationManager.createNotificationChannelGroup(channelGroup)

            val id = mapData["id"]
            val descriptionText = mapData["description"]
            val sound = "res_brodio"
            val importance = NotificationManager.IMPORTANCE_HIGH
            val mChannel = NotificationChannel(id, name, importance)
            mChannel.description = descriptionText

            val soundUri = Uri.parse(ContentResolver.SCHEME_ANDROID_RESOURCE + "://"+ getApplicationContext().getPackageName() + "/raw/res_brodio");
            val att = AudioAttributes.Builder()
                    .setUsage(AudioAttributes.USAGE_NOTIFICATION)
                    .setContentType(AudioAttributes.CONTENT_TYPE_SPEECH)
                    .build();

            mChannel.setSound(soundUri, att)
            mChannel.setGroup(channelGroup.getId());

            notificationManager.createNotificationChannel(mChannel)

            completed = true
        }
        else{
            completed = false
        }
        return completed
    }
}