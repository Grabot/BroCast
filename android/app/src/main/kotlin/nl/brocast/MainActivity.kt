package nl.brocast

import android.graphics.Paint
import androidx.annotation.NonNull
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel


class MainActivity: FlutterActivity() {
    private val CHANNEL = "com.flutter.epic/epic"

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            if (call.method.equals("isAvailable")) {
                val paint = Paint()
                val emojiAvailable = call.argument<String>("emoji")
                if (paint.hasGlyph(emojiAvailable)) {
                    result.success("true")
                } else {
                    result.success("false")
                }
            }
        }
    }
}