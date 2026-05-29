package com.inrego.speakr_app.audio

import android.annotation.SuppressLint
import android.content.Context
import android.media.AudioAttributes
import android.media.AudioFormat
import android.media.AudioPlaybackCaptureConfiguration
import android.media.AudioRecord
import android.media.MediaCodec
import android.media.MediaCodecInfo
import android.media.MediaFormat
import android.media.MediaMuxer
import android.media.MediaRecorder
import android.media.projection.MediaProjection
import android.media.projection.MediaProjectionManager
import android.os.Build
import android.util.Log
import io.flutter.plugin.common.MethodChannel
import kotlin.math.sqrt
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.Job
import kotlinx.coroutines.cancel
import kotlinx.coroutines.launch
import kotlinx.coroutines.runBlocking
import kotlinx.coroutines.sync.Mutex
import kotlinx.coroutines.sync.withLock
import java.io.File
import java.nio.ByteBuffer
import java.util.concurrent.atomic.AtomicBoolean

/**
 * Android-side implementation of the `speakr.audio/recorder` channel.
 *
 *  - Mic source: `AudioRecord` reading 16-bit mono PCM at 48 kHz.
 *  - System source: `AudioPlaybackCaptureConfiguration` on top of a
 *    `MediaProjection` obtained via [ProjectionConsentBridge] (API 29+).
 *  - Encoder: `MediaCodec` (AAC LC, 128 kbps, 48 kHz stereo).
 *  - Muxer: `MediaMuxer` (.m4a container).
 *
 * Per-source live mute is implemented by replacing the source's PCM
 * buffer with zeros before mixing — the encoder timeline stays
 * continuous, so the output file always has valid silent frames in the
 * gap between two enables. Mirrors the Windows pipeline.
 */
class SpeakrAudioRecorder(
    private val context: Context,
    private val consent: ProjectionConsentBridge?,
) {
    companion object {
        private const val TAG = "SpeakrAudioRecorder"
        private const val SAMPLE_RATE = 48_000
        private const val CHANNELS = 2
        private const val BIT_RATE = 128_000
        private const val FRAMES_PER_CHUNK = 960  // 20 ms @ 48 kHz
    }

    private val scope = CoroutineScope(Dispatchers.Default)
    private var sessionJob: Job? = null
    private val mutex = Mutex()

    private val micEnabled = AtomicBoolean(true)
    private val systemEnabled = AtomicBoolean(false)
    private val paused = AtomicBoolean(false)
    private val running = AtomicBoolean(false)
    private val stopRequested = AtomicBoolean(false)

    private var outputPath: String? = null
    private var lastError: String? = null
    private var projection: MediaProjection? = null
    private var pendingProjectionResult: ProjectionResult? = null

    // Level meter buffer — the worker writes the latest RMS-derived
    // level here on every mixed chunk; Dart polls it via the `getLevel`
    // MethodChannel call (~20 Hz). We can't push from the worker because
    // EventChannel sinks must be invoked on the platform thread, and
    // bouncing through Looper.getMainLooper() still triggers Flutter's
    // platform-thread assertion on Windows-style embeddings.
    @Volatile private var lastLevel: Double = 0.0

    fun getLevel(): Double = lastLevel

    private fun storeLevel(linear: Double) {
        lastLevel = when {
            linear.isNaN() -> 0.0
            linear < 0.0 -> 0.0
            linear > 1.0 -> 1.0
            else -> linear
        }
    }

    fun supportsSystemAudio(): Boolean {
        return Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q
    }

    fun isRecording(): Boolean = running.get() && !stopRequested.get()

    /**
     * Launch the OS consent flow and cache the result for the next
     * [start] call. Required before activating system-audio capture on
     * Android 10+. Returns false if the user denied or the platform is
     * too old.
     */
    suspend fun requestSystemPermission(): Boolean {
        if (!supportsSystemAudio()) return false
        val bridge = consent ?: return false
        val result = bridge.request() ?: return false
        pendingProjectionResult = result
        return true
    }

    fun start(path: String, micOn: Boolean, sysOn: Boolean, onDone: (String?) -> Unit) {
        scope.launch {
            mutex.withLock {
                if (running.get()) {
                    onDone("Recorder is already running.")
                    return@withLock
                }
                if (path.isBlank()) {
                    onDone("Output path is empty.")
                    return@withLock
                }
                outputPath = path
                micEnabled.set(micOn)
                systemEnabled.set(sysOn)
                paused.set(false)
                stopRequested.set(false)
                lastError = null
                lastLevel = 0.0

                // System capture needs a MediaProjection — use the cached
                // one if we have it, otherwise request now.
                if (sysOn) {
                    if (pendingProjectionResult == null) {
                        if (!requestSystemPermission()) {
                            onDone("System-audio permission denied.")
                            return@withLock
                        }
                    }
                }

                // Start the foreground service before activating projection.
                // Only request the mediaProjection FGS type when we have a
                // consent token — without one, Android 14+ rejects the
                // startForeground call with SecurityException.
                val useProjection = sysOn && pendingProjectionResult != null
                AudioCaptureService.start(context, useProjection)
                running.set(true)
                sessionJob = scope.launch { runSession() }
                onDone(null)
            }
        }
    }

    fun setMicEnabled(v: Boolean) { micEnabled.set(v) }
    fun setSystemEnabled(v: Boolean) { systemEnabled.set(v) }
    fun pause() { paused.set(true) }
    fun resume() { paused.set(false) }

    fun stop(onDone: (String?) -> Unit) {
        scope.launch {
            val out: String? = runBlockingStop()
            onDone(out)
        }
    }

    private suspend fun runBlockingStop(): String? {
        if (!running.get()) return null
        stopRequested.set(true)
        sessionJob?.join()
        running.set(false)
        AudioCaptureService.stop(context)
        return if (lastError != null) null else outputPath
    }

    fun dispose() {
        runBlocking {
            if (running.get()) runBlockingStop()
        }
        scope.cancel()
    }

    // ----- Session worker -----

    @SuppressLint("MissingPermission")
    private suspend fun runSession() {
        val path = outputPath ?: return

        val muxer = try {
            MediaMuxer(path, MediaMuxer.OutputFormat.MUXER_OUTPUT_MPEG_4)
        } catch (t: Throwable) {
            lastError = "MediaMuxer init failed: ${t.message}"
            return
        }

        val outFmt = MediaFormat.createAudioFormat(
            MediaFormat.MIMETYPE_AUDIO_AAC, SAMPLE_RATE, CHANNELS
        ).apply {
            setInteger(MediaFormat.KEY_AAC_PROFILE,
                MediaCodecInfo.CodecProfileLevel.AACObjectLC)
            setInteger(MediaFormat.KEY_BIT_RATE, BIT_RATE)
            setInteger(MediaFormat.KEY_MAX_INPUT_SIZE, 16384)
        }
        val codec = try {
            MediaCodec.createEncoderByType(MediaFormat.MIMETYPE_AUDIO_AAC).apply {
                configure(outFmt, null, null, MediaCodec.CONFIGURE_FLAG_ENCODE)
                start()
            }
        } catch (t: Throwable) {
            lastError = "AAC encoder init failed: ${t.message}"
            try { muxer.release() } catch (_: Throwable) {}
            return
        }

        // Open mic input.
        val micBufSize = AudioRecord.getMinBufferSize(
            SAMPLE_RATE, AudioFormat.CHANNEL_IN_MONO,
            AudioFormat.ENCODING_PCM_16BIT
        ).coerceAtLeast(FRAMES_PER_CHUNK * 2)
        val mic = try {
            AudioRecord(
                MediaRecorder.AudioSource.MIC,
                SAMPLE_RATE, AudioFormat.CHANNEL_IN_MONO,
                AudioFormat.ENCODING_PCM_16BIT, micBufSize
            )
        } catch (t: Throwable) {
            lastError = "Mic AudioRecord init failed: ${t.message}"
            try { codec.stop(); codec.release() } catch (_: Throwable) {}
            try { muxer.release() } catch (_: Throwable) {}
            return
        }

        // System (loopback) input via MediaProjection.
        var sysRecord: AudioRecord? = null
        if (systemEnabled.get() && supportsSystemAudio()) {
            val res = pendingProjectionResult
            if (res != null) {
                try {
                    val mgr = context.getSystemService(Context.MEDIA_PROJECTION_SERVICE)
                        as MediaProjectionManager
                    projection = mgr.getMediaProjection(res.resultCode, res.data)
                    pendingProjectionResult = null
                    projection!!.registerCallback(object : MediaProjection.Callback() {
                        override fun onStop() {
                            // OS revoked projection — gate system to silence.
                            systemEnabled.set(false)
                            lastError = "System-audio projection was revoked."
                        }
                    }, null)
                    val cfg = AudioPlaybackCaptureConfiguration.Builder(projection!!)
                        .addMatchingUsage(AudioAttributes.USAGE_MEDIA)
                        .addMatchingUsage(AudioAttributes.USAGE_GAME)
                        .addMatchingUsage(AudioAttributes.USAGE_UNKNOWN)
                        .build()
                    val sysBufSize = AudioRecord.getMinBufferSize(
                        SAMPLE_RATE, AudioFormat.CHANNEL_IN_STEREO,
                        AudioFormat.ENCODING_PCM_16BIT
                    ).coerceAtLeast(FRAMES_PER_CHUNK * 4)
                    sysRecord = AudioRecord.Builder()
                        .setAudioFormat(
                            AudioFormat.Builder()
                                .setEncoding(AudioFormat.ENCODING_PCM_16BIT)
                                .setSampleRate(SAMPLE_RATE)
                                .setChannelMask(AudioFormat.CHANNEL_IN_STEREO)
                                .build()
                        )
                        .setBufferSizeInBytes(sysBufSize)
                        .setAudioPlaybackCaptureConfig(cfg)
                        .build()
                } catch (t: Throwable) {
                    Log.w(TAG, "system capture init failed: ${t.message}")
                    sysRecord = null
                }
            }
        }

        try {
            mic.startRecording()
            sysRecord?.startRecording()
        } catch (t: Throwable) {
            lastError = "AudioRecord.startRecording failed: ${t.message}"
            mic.release()
            sysRecord?.release()
            try { codec.stop(); codec.release() } catch (_: Throwable) {}
            try { muxer.release() } catch (_: Throwable) {}
            return
        }

        var muxerTrackIndex = -1
        var muxerStarted = false
        var ptsUs = 0L
        val micBuf = ShortArray(FRAMES_PER_CHUNK)
        val sysBuf = ShortArray(FRAMES_PER_CHUNK * 2)
        val mixed = ShortArray(FRAMES_PER_CHUNK * 2)
        val codecInfo = MediaCodec.BufferInfo()
        var chunkCounter = 0L

        while (!stopRequested.get()) {
            // Read mic mono → mixed stereo (duplicated to L+R).
            val micRead = mic.read(micBuf, 0, FRAMES_PER_CHUNK)
            val haveMic = micEnabled.get() && micRead > 0
            // Read system stereo.
            val sysRead = sysRecord?.read(sysBuf, 0, FRAMES_PER_CHUNK * 2) ?: 0
            val haveSys = systemEnabled.get() && sysRead > 0
            // Track per-source RMS so the breathing dot reflects either
            // source independently. RMS over the mix biases towards
            // whichever source has the louder noise floor (typically
            // the mic), so quiet system audio never registers.
            var micSumSq = 0.0
            var sysSumSq = 0.0
            for (i in 0 until FRAMES_PER_CHUNK) {
                val mLeft = if (haveMic && i < micRead) micBuf[i].toInt() else 0
                val mRight = mLeft
                val sLeft = if (haveSys && i * 2 < sysRead) sysBuf[i * 2].toInt() else 0
                val sRight = if (haveSys && i * 2 + 1 < sysRead) sysBuf[i * 2 + 1].toInt() else 0
                var l = mLeft + sLeft
                var r = mRight + sRight
                if (l > Short.MAX_VALUE) l = Short.MAX_VALUE.toInt()
                if (l < Short.MIN_VALUE) l = Short.MIN_VALUE.toInt()
                if (r > Short.MAX_VALUE) r = Short.MAX_VALUE.toInt()
                if (r < Short.MIN_VALUE) r = Short.MIN_VALUE.toInt()
                mixed[i * 2] = l.toShort()
                mixed[i * 2 + 1] = r.toShort()
                val mNorm = mLeft.toDouble() / 32768.0
                val sLeftNorm = sLeft.toDouble() / 32768.0
                val sRightNorm = sRight.toDouble() / 32768.0
                micSumSq += mNorm * mNorm * 2.0  // mono → both channels
                sysSumSq += sLeftNorm * sLeftNorm + sRightNorm * sRightNorm
            }

            if (paused.get()) {
                storeLevel(0.0)
                continue
            }

            // dB-linear VU mapping per source; the meter shows whichever
            // is louder. -55 dBFS → floor, -12 dBFS → full.
            val micRms = sqrt(micSumSq / (FRAMES_PER_CHUNK * 2.0))
            val sysRms = sqrt(sysSumSq / (FRAMES_PER_CHUNK * 2.0))
            val kFloorDb = -55.0
            val kCeilDb = -12.0
            fun rmsToLevel(r: Double): Double = if (r < 1e-6) 0.0 else {
                val db = 20.0 * kotlin.math.log10(r)
                ((db - kFloorDb) / (kCeilDb - kFloorDb)).coerceIn(0.0, 1.0)
            }
            val level = maxOf(rmsToLevel(micRms), rmsToLevel(sysRms))
            storeLevel(level)
            if (chunkCounter % 50L == 0L) {
                Log.d(TAG, "level mic=%.3f (rms=%.4f) sys=%.3f (rms=%.4f) " +
                    "haveSys=%b sysEnabled=%b".format(
                        rmsToLevel(micRms), micRms,
                        rmsToLevel(sysRms), sysRms,
                        sysRecord != null, systemEnabled.get()))
            }
            chunkCounter++

            // Feed encoder.
            val inIdx = codec.dequeueInputBuffer(10_000)
            if (inIdx >= 0) {
                val ib: ByteBuffer = codec.getInputBuffer(inIdx) ?: continue
                ib.clear()
                for (s in mixed) {
                    ib.putShort(s)
                }
                codec.queueInputBuffer(inIdx, 0, mixed.size * 2, ptsUs, 0)
                ptsUs += 1_000_000L * FRAMES_PER_CHUNK / SAMPLE_RATE
            }

            var outIdx = codec.dequeueOutputBuffer(codecInfo, 0)
            while (outIdx >= 0) {
                val ob = codec.getOutputBuffer(outIdx)
                if (ob != null && codecInfo.size > 0 &&
                    codecInfo.flags and MediaCodec.BUFFER_FLAG_CODEC_CONFIG == 0
                ) {
                    if (!muxerStarted) {
                        muxerTrackIndex = muxer.addTrack(codec.outputFormat)
                        muxer.start()
                        muxerStarted = true
                    }
                    if (muxerStarted) {
                        ob.position(codecInfo.offset)
                        ob.limit(codecInfo.offset + codecInfo.size)
                        muxer.writeSampleData(muxerTrackIndex, ob, codecInfo)
                    }
                }
                codec.releaseOutputBuffer(outIdx, false)
                outIdx = codec.dequeueOutputBuffer(codecInfo, 0)
            }
        }

        // Drain encoder.
        try {
            val inIdx = codec.dequeueInputBuffer(10_000)
            if (inIdx >= 0) {
                codec.queueInputBuffer(inIdx, 0, 0, ptsUs,
                    MediaCodec.BUFFER_FLAG_END_OF_STREAM)
            }
            var outIdx = codec.dequeueOutputBuffer(codecInfo, 100_000)
            while (outIdx >= 0) {
                val ob = codec.getOutputBuffer(outIdx)
                if (ob != null && codecInfo.size > 0 && muxerStarted) {
                    ob.position(codecInfo.offset)
                    ob.limit(codecInfo.offset + codecInfo.size)
                    muxer.writeSampleData(muxerTrackIndex, ob, codecInfo)
                }
                codec.releaseOutputBuffer(outIdx, false)
                if (codecInfo.flags and MediaCodec.BUFFER_FLAG_END_OF_STREAM != 0) break
                outIdx = codec.dequeueOutputBuffer(codecInfo, 100_000)
            }
        } catch (t: Throwable) {
            Log.w(TAG, "encoder drain failed: ${t.message}")
        }

        try { mic.stop(); mic.release() } catch (_: Throwable) {}
        try { sysRecord?.stop(); sysRecord?.release() } catch (_: Throwable) {}
        try { projection?.stop() } catch (_: Throwable) {}
        projection = null
        try {
            codec.stop()
            codec.release()
        } catch (_: Throwable) {}
        try {
            if (muxerStarted) muxer.stop()
            muxer.release()
        } catch (_: Throwable) {}

        // Session wound down — flush the meter so the dot collapses on
        // the next poll.
        storeLevel(0.0)

        if (lastError != null) {
            try { File(path).delete() } catch (_: Throwable) {}
        }
    }
}
