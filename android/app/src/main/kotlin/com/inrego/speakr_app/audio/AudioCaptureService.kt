package com.inrego.speakr_app.audio

import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.Service
import android.content.Context
import android.content.Intent
import android.content.pm.ServiceInfo
import android.os.Build
import android.os.IBinder

/**
 * Foreground service that keeps the recorder alive while a session is
 * running. We don't put recording logic here — it lives on the worker
 * thread owned by [SpeakrAudioRecorder]. The service exists so that:
 *
 *  1. Android lets us hold an active `MediaProjection` (required for
 *     system-audio capture).
 *  2. Mic capture continues when the screen is off / app is backgrounded.
 *
 * The recorder calls [start] when a session begins and [stop] when it
 * ends. Failing to call [start] before activating a `MediaProjection`
 * is a runtime crash on Android 10+.
 */
class AudioCaptureService : Service() {
    override fun onBind(intent: Intent?): IBinder? = null

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        ensureChannel(this)
        val notification = buildNotification(this, "Recording…")
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.UPSIDE_DOWN_CAKE) {
            // The mediaProjection FGS type requires the project_media
            // appop — only granted by an active MediaProjection consent
            // token. Requesting it without a token (mic-only sessions)
            // is a SecurityException on Android 14+ (targetSDK 34+).
            val useProjection = intent?.getBooleanExtra(EXTRA_USE_MEDIA_PROJECTION, false) ?: false
            var type = ServiceInfo.FOREGROUND_SERVICE_TYPE_MICROPHONE
            if (useProjection) {
                type = type or ServiceInfo.FOREGROUND_SERVICE_TYPE_MEDIA_PROJECTION
            }
            startForeground(NOTIF_ID, notification, type)
            projectionTypeActive = useProjection
        } else {
            startForeground(NOTIF_ID, notification)
            projectionTypeActive = true
        }
        return START_NOT_STICKY
    }

    override fun onDestroy() {
        projectionTypeActive = false
        try {
            stopForeground(STOP_FOREGROUND_REMOVE)
        } catch (_: Throwable) {}
        super.onDestroy()
    }

    companion object {
        private const val CHANNEL_ID = "speakr_recording"
        private const val CHANNEL_NAME = "Recording"
        private const val NOTIF_ID = 0x53504B52  // 'SPKR'
        private const val EXTRA_USE_MEDIA_PROJECTION = "use_media_projection"

        /**
         * True once the service is in the foreground with the
         * mediaProjection type (always true below Android 14, which has no
         * FGS types to check). `getMediaProjection` throws before that, so
         * the recorder waits on this after asking [start] to add the type
         * mid-session.
         */
        @Volatile
        var projectionTypeActive = false
            private set

        fun start(ctx: Context, useMediaProjection: Boolean) {
            val intent = Intent(ctx, AudioCaptureService::class.java)
                .putExtra(EXTRA_USE_MEDIA_PROJECTION, useMediaProjection)
            // Don't let a stale `true` (a service instance that has not
            // been torn down yet) open the projection before this start
            // command has been processed; onStartCommand sets it again.
            if (useMediaProjection) projectionTypeActive = false
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                ctx.startForegroundService(intent)
            } else {
                ctx.startService(intent)
            }
        }

        fun stop(ctx: Context) {
            ctx.stopService(Intent(ctx, AudioCaptureService::class.java))
        }

        private fun ensureChannel(ctx: Context) {
            if (Build.VERSION.SDK_INT < Build.VERSION_CODES.O) return
            val nm = ctx.getSystemService(NotificationManager::class.java) ?: return
            if (nm.getNotificationChannel(CHANNEL_ID) != null) return
            val ch = NotificationChannel(
                CHANNEL_ID, CHANNEL_NAME,
                NotificationManager.IMPORTANCE_LOW
            ).apply {
                description = "Live recording is in progress"
                setSound(null, null)
                enableVibration(false)
            }
            nm.createNotificationChannel(ch)
        }

        private fun buildNotification(ctx: Context, text: String): Notification {
            val builder = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                Notification.Builder(ctx, CHANNEL_ID)
            } else {
                @Suppress("DEPRECATION")
                Notification.Builder(ctx)
            }
            return builder
                .setContentTitle("Minutes recording")
                .setContentText(text)
                .setSmallIcon(android.R.drawable.ic_btn_speak_now)
                .setOngoing(true)
                .build()
        }
    }
}
