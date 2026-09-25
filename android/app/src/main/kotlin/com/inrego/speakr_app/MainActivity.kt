package com.inrego.speakr_app

import androidx.lifecycle.lifecycleScope
import com.inrego.speakr_app.audio.ProjectionConsentBridge
import com.inrego.speakr_app.audio.SpeakrAudioRecorder
import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import kotlinx.coroutines.launch

class MainActivity : FlutterFragmentActivity() {
    private var consentBridge: ProjectionConsentBridge? = null
    private var recorder: SpeakrAudioRecorder? = null

    override fun onCreate(savedInstanceState: android.os.Bundle?) {
        // The Activity Result API must be registered before `onStart`, so
        // build the consent bridge here while we're still in `onCreate`.
        consentBridge = ProjectionConsentBridge(this)
        super.onCreate(savedInstanceState)
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        val rec = SpeakrAudioRecorder(applicationContext, consentBridge)
        recorder = rec
        val channel = MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            "speakr.audio/recorder"
        )
        channel.setMethodCallHandler { call, result ->
            when (call.method) {
                "supportsSystemAudio" -> result.success(rec.supportsSystemAudio())
                "isRecording" -> result.success(rec.isRecording())
                "getLevel" -> result.success(rec.getLevel())
                "requestSystemPermission" -> {
                    lifecycleScope.launch {
                        val ok = try {
                            rec.requestSystemPermission()
                        } catch (t: Throwable) {
                            false
                        }
                        result.success(ok)
                    }
                }
                "start" -> {
                    val path = call.argument<String>("path") ?: ""
                    val mic = call.argument<Boolean>("micEnabled") ?: true
                    // Dart sends `systemMode` ("off" | "all" | "process");
                    // Android has no per-process capture, so any non-off
                    // mode means whole-device playback capture.
                    val mode = call.argument<String>("systemMode")
                    val sys = if (mode != null) mode != "off"
                        else call.argument<Boolean>("systemEnabled") ?: false
                    rec.start(path, mic, sys) { err ->
                        runOnUiThread {
                            if (err == null) result.success(null)
                            else result.error("start_failed", err, null)
                        }
                    }
                }
                "setMicEnabled" -> {
                    val v = call.argument<Boolean>("enabled") ?: true
                    rec.setMicEnabled(v)
                    result.success(null)
                }
                "setSystemMode" -> {
                    val mode = call.argument<String>("mode") ?: "off"
                    rec.setSystemEnabled(mode != "off")
                    result.success(null)
                }
                "pause" -> { rec.pause(); result.success(null) }
                "resume" -> { rec.resume(); result.success(null) }
                "stop" -> {
                    rec.stop { path ->
                        runOnUiThread {
                            if (path == null) result.success(null)
                            else result.success(path)
                        }
                    }
                }
                "dispose" -> {
                    rec.dispose()
                    recorder = null
                    result.success(null)
                }
                else -> result.notImplemented()
            }
        }
    }

    override fun onDestroy() {
        try { recorder?.dispose() } catch (_: Throwable) {}
        recorder = null
        super.onDestroy()
    }
}
