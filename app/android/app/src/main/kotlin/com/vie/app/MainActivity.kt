package com.vie.app

import android.app.NotificationManager
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.graphics.Color
import androidx.core.app.NotificationCompat
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    companion object {
        private const val CHANNEL = "com.vie.app/workout_notification"
        private const val NOTIFICATION_ID = 101
        private const val CHANNEL_ID = "vie_workout_channel_v3"
        private const val ACTION_BUTTON = "onNotificationButtonPressed"
        private const val INTENT_DATA = "intentData"
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "updateProgress" -> {
                    val max = call.argument<Int>("max") ?: 100
                    val progress = call.argument<Int>("progress") ?: 0
                    val title = call.argument<String>("title") ?: ""
                    val text = call.argument<String>("text") ?: ""
                    val isRunning = call.argument<Boolean>("isRunning") ?: true
                    updateNotification(max, progress, title, text, isRunning)
                    result.success(true)
                }
                else -> result.notImplemented()
            }
        }
    }

    private fun updateNotification(max: Int, progress: Int, title: String, text: String, isRunning: Boolean) {
        val nm = getSystemService(Context.NOTIFICATION_SERVICE) as? NotificationManager ?: return
        val launchIntent = packageManager.getLaunchIntentForPackage(packageName)
        val contentPendingIntent = PendingIntent.getActivity(
            this, 0, launchIntent, PendingIntent.FLAG_IMMUTABLE or PendingIntent.FLAG_UPDATE_CURRENT
        )

        val add30Intent = createButtonIntent(1, "add_30s")
        val toggleIntent = createButtonIntent(2, "toggle_pause")
        val skipIntent = createButtonIntent(3, "skip_rest")

        val builder = NotificationCompat.Builder(this, CHANNEL_ID)
            .setSmallIcon(R.mipmap.ic_launcher)
            .setContentTitle(title)
            .setContentText(text)
            .setStyle(NotificationCompat.BigTextStyle().bigText(text))
            .setProgress(max, progress, false)
            .setOngoing(true)
            .setOnlyAlertOnce(true)
            .setColor(Color.parseColor("#6C5CE7"))
            .setContentIntent(contentPendingIntent)
            .addAction(0, "+30s", add30Intent)
            .addAction(0, if (isRunning) "Pausar" else "Reanudar", toggleIntent)
            .addAction(0, "Saltar", skipIntent)

        nm.notify(NOTIFICATION_ID, builder.build())
    }

    private fun createButtonIntent(requestCode: Int, data: String): PendingIntent {
        val intent = Intent(ACTION_BUTTON).apply {
            setPackage(packageName)
            putExtra(INTENT_DATA, data)
        }
        return PendingIntent.getBroadcast(
            this, requestCode, intent, PendingIntent.FLAG_IMMUTABLE or PendingIntent.FLAG_UPDATE_CURRENT
        )
    }
}
