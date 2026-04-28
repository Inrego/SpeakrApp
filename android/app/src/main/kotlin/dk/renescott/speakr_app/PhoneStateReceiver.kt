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

// On call end (OFFHOOK -> IDLE), enqueues a one-shot WorkManager job that
// resumes the Dart auto-upload scan via the workmanager plugin's
// BackgroundWorker. Survives the app being killed: WorkManager spawns a
// fresh Flutter isolate from the previously-registered callback handle.
class PhoneStateReceiver : BroadcastReceiver() {
    companion object {
        private const val UNIQUE_WORK_NAME = "speakr.autoUpload.callEnded"
        private const val DART_TASK_NAME = "speakr.autoUpload.scan"
        private var lastState: String? = null
    }

    override fun onReceive(context: Context, intent: Intent) {
        if (intent.action != TelephonyManager.ACTION_PHONE_STATE_CHANGED) return
        val state = intent.getStringExtra(TelephonyManager.EXTRA_STATE) ?: return
        val previous = lastState
        lastState = state
        if (state != TelephonyManager.EXTRA_STATE_IDLE) return
        if (previous != TelephonyManager.EXTRA_STATE_OFFHOOK) return

        val data = Data.Builder()
            .putString("dev.fluttercommunity.workmanager.DART_TASK", DART_TASK_NAME)
            .build()
        val request = OneTimeWorkRequest.Builder(BackgroundWorker::class.java)
            .setInputData(data)
            .build()
        WorkManager.getInstance(context).enqueueUniqueWork(
            UNIQUE_WORK_NAME,
            ExistingWorkPolicy.KEEP,
            request
        )
    }
}
