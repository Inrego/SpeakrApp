package com.inrego.speakr_app.audio

import android.app.Activity
import android.content.Intent
import android.media.projection.MediaProjectionManager
import androidx.activity.ComponentActivity
import androidx.activity.result.ActivityResultLauncher
import androidx.activity.result.contract.ActivityResultContracts
import kotlinx.coroutines.CompletableDeferred

/**
 * Plumbing for the MediaProjection consent dialog. The Android Activity
 * Result API can only be registered before `onStart`, so MainActivity
 * eagerly creates one and exposes it through this bridge. The recorder
 * suspends on [request] until the user has accepted or denied.
 *
 * Multiple in-flight requests aren't supported — if [request] is called
 * while a previous one is pending, the new caller wins and the old one
 * resolves to null.
 */
class ProjectionConsentBridge(private val activity: ComponentActivity) {
    private val mgr by lazy {
        activity.getSystemService(Activity.MEDIA_PROJECTION_SERVICE) as MediaProjectionManager
    }
    private var pending: CompletableDeferred<ProjectionResult?>? = null
    private val launcher: ActivityResultLauncher<Intent> =
        activity.registerForActivityResult(
            ActivityResultContracts.StartActivityForResult()
        ) { result ->
            val def = pending
            pending = null
            if (def == null) return@registerForActivityResult
            if (result.resultCode == Activity.RESULT_OK && result.data != null) {
                def.complete(ProjectionResult(result.resultCode, result.data!!))
            } else {
                def.complete(null)
            }
        }

    suspend fun request(): ProjectionResult? {
        pending?.complete(null)
        val def = CompletableDeferred<ProjectionResult?>()
        pending = def
        try {
            launcher.launch(mgr.createScreenCaptureIntent())
        } catch (t: Throwable) {
            pending = null
            return null
        }
        return def.await()
    }
}

data class ProjectionResult(val resultCode: Int, val data: Intent)
