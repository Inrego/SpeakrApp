package dk.renescott.speakr_app

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.telephony.TelephonyManager
import androidx.work.Data
import androidx.work.ExistingWorkPolicy
import androidx.work.OneTimeWorkRequest
import androidx.work.WorkManager
import dev.fluttercommunity.workmanager.BackgroundWorker
import java.util.concurrent.TimeUnit

// On call end (OFFHOOK -> IDLE), enqueues a one-shot WorkManager job that
// resumes the Dart auto-upload scan via the workmanager plugin's
// BackgroundWorker. Survives the app being killed: WorkManager spawns a
// fresh Flutter isolate from the previously-registered callback handle.
//
// State and breadcrumbs are persisted to SharedPreferences (not a
// companion-object static) so the OFFHOOK -> IDLE machine survives
// process death — on OEMs that aggressively reclaim background app
// processes between call events, a static `lastState` would reset to
// null and the IDLE branch would silently skip.
//
// Every broadcast also writes a breadcrumb (state, previous, decision,
// timestamp) so the UI's Auto-upload settings can show whether the
// receiver is firing at all and what it decided to do.
class PhoneStateReceiver : BroadcastReceiver() {
    companion object {
        private const val UNIQUE_WORK_NAME = "speakr.autoUpload.callEnded"
        private const val DART_TASK_NAME = "speakr.autoUpload.scan"

        // Same SharedPreferences file the Flutter shared_preferences plugin
        // uses on Android; the Dart side reads keys without the "flutter."
        // prefix (the plugin auto-strips it).
        private const val PREFS_NAME = "FlutterSharedPreferences"
        private const val K_LAST_STATE = "flutter.auto_upload.last_phone_state"
        private const val K_LAST_STATE_MS = "flutter.auto_upload.last_phone_state_ms"
        private const val K_LAST_PREV = "flutter.auto_upload.last_phone_state_prev"
        private const val K_LAST_DECISION = "flutter.auto_upload.last_phone_state_decision"
        private const val K_LAST_ENQUEUE_MS = "flutter.auto_upload.last_call_end_enqueue_ms"
    }

    override fun onReceive(context: Context, intent: Intent) {
        if (intent.action != TelephonyManager.ACTION_PHONE_STATE_CHANGED) return
        val state = intent.getStringExtra(TelephonyManager.EXTRA_STATE) ?: return

        val prefs = context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
        val previous = prefs.getString(K_LAST_STATE, null)
        val now = System.currentTimeMillis()

        val decision: String = if (
            state == TelephonyManager.EXTRA_STATE_IDLE &&
            previous == TelephonyManager.EXTRA_STATE_OFFHOOK
        ) {
            try {
                val data = Data.Builder()
                    .putString("dev.fluttercommunity.workmanager.DART_TASK", DART_TASK_NAME)
                    .build()
                val request = OneTimeWorkRequest.Builder(BackgroundWorker::class.java)
                    .setInputData(data)
                    // Run ~40s after IDLE so the recorder has finished
                    // flushing and the file's mtime is past the Dart
                    // worker's 30s grace window.
                    .setInitialDelay(40, TimeUnit.SECONDS)
                    .build()
                WorkManager.getInstance(context).enqueueUniqueWork(
                    UNIQUE_WORK_NAME,
                    ExistingWorkPolicy.KEEP,
                    request
                )
                prefs.edit().putLong(K_LAST_ENQUEUE_MS, now).apply()
                "enqueued"
            } catch (e: Throwable) {
                "enqueue_failed: ${e.javaClass.simpleName}: ${e.message ?: ""}"
            }
        } else {
            "no_op (state=$state prev=${previous ?: "null"})"
        }

        prefs.edit()
            .putString(K_LAST_STATE, state)
            .putLong(K_LAST_STATE_MS, now)
            .putString(K_LAST_PREV, previous ?: "null")
            .putString(K_LAST_DECISION, decision)
            .apply()
    }
}
