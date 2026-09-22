package com.inrego.speakr_saf

import android.app.Activity
import android.content.Context
import android.content.Intent
import android.net.Uri
import android.os.Environment
import android.os.Handler
import android.os.Looper
import android.provider.DocumentsContract
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.PluginRegistry
import java.io.File
import java.io.FileOutputStream
import java.util.concurrent.Executors

/**
 * Storage Access Framework bridge for the auto-upload feature.
 *
 * Registered through GeneratedPluginRegistrant, so it is attached both to the
 * UI engine (where the folder picker needs an Activity) and to the
 * WorkManager background engine (where only the headless calls are used).
 *
 * All document I/O runs on a single worker thread; results are posted back
 * to the main looper as the Flutter binary messenger requires.
 */
class SpeakrSafPlugin :
    FlutterPlugin,
    ActivityAware,
    MethodChannel.MethodCallHandler,
    PluginRegistry.ActivityResultListener {

    companion object {
        const val CHANNEL = "com.inrego.speakr_saf"
        private const val REQUEST_PICK_TREE = 0x5AF1
        private const val EXTERNAL_STORAGE_AUTHORITY =
            "com.android.externalstorage.documents"
        private const val PERSIST_FLAGS =
            Intent.FLAG_GRANT_READ_URI_PERMISSION or
                Intent.FLAG_GRANT_WRITE_URI_PERMISSION
    }

    private lateinit var context: Context
    private var channel: MethodChannel? = null
    private var activityBinding: ActivityPluginBinding? = null
    private var pendingPick: MethodChannel.Result? = null

    private val io = Executors.newSingleThreadExecutor()
    private val main = Handler(Looper.getMainLooper())

    // ── FlutterPlugin ─────────────────────────────────────────────────────────

    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        context = binding.applicationContext
        channel = MethodChannel(binding.binaryMessenger, CHANNEL).also {
            it.setMethodCallHandler(this)
        }
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel?.setMethodCallHandler(null)
        channel = null
    }

    // ── ActivityAware ─────────────────────────────────────────────────────────

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        activityBinding = binding
        binding.addActivityResultListener(this)
    }

    override fun onDetachedFromActivityForConfigChanges() {
        activityBinding?.removeActivityResultListener(this)
        activityBinding = null
    }

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
        onAttachedToActivity(binding)
    }

    override fun onDetachedFromActivity() {
        activityBinding?.removeActivityResultListener(this)
        activityBinding = null
    }

    // ── MethodCallHandler ─────────────────────────────────────────────────────

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "pickTree" -> pickTree(call.argument<String>("initialUri"), result)
            "hasPersistedPermission" -> {
                val uri = call.argument<String>("treeUri")
                if (uri == null) {
                    result.error("bad_args", "treeUri is required", null)
                } else {
                    result.success(hasPersistedPermission(Uri.parse(uri)))
                }
            }
            "releaseTree" -> {
                val uri = call.argument<String>("treeUri")
                if (uri != null) {
                    try {
                        context.contentResolver.releasePersistableUriPermission(
                            Uri.parse(uri), PERSIST_FLAGS
                        )
                    } catch (_: Throwable) {
                        // Already released or never held; nothing to do.
                    }
                }
                result.success(null)
            }
            "listChildren" -> background(result) {
                val uri = requireArg(call, "treeUri")
                listChildren(Uri.parse(uri))
            }
            "statDocument" -> background(result) {
                val uri = requireArg(call, "documentUri")
                statDocument(Uri.parse(uri))
            }
            "copyToFile" -> background(result) {
                val uri = requireArg(call, "documentUri")
                val dest = requireArg(call, "destinationPath")
                copyToFile(Uri.parse(uri), File(dest))
            }
            "deleteDocument" -> background(result) {
                val uri = requireArg(call, "documentUri")
                DocumentsContract.deleteDocument(context.contentResolver, Uri.parse(uri))
            }
            else -> result.notImplemented()
        }
    }

    private fun requireArg(call: MethodCall, name: String): String =
        call.argument<String>(name)
            ?: throw IllegalArgumentException("$name is required")

    /** Runs [block] on the I/O thread and delivers its value or error to [result]. */
    private fun background(result: MethodChannel.Result, block: () -> Any?) {
        io.execute {
            val outcome = try {
                Pair(block(), null as Throwable?)
            } catch (t: Throwable) {
                Pair(null, t)
            }
            main.post {
                val (value, error) = outcome
                if (error == null) {
                    result.success(value)
                } else {
                    result.error(codeFor(error), error.message ?: error.toString(), null)
                }
            }
        }
    }

    private fun codeFor(t: Throwable): String = when (t) {
        is SecurityException -> "permission_lost"
        is java.io.FileNotFoundException -> "not_found"
        is IllegalArgumentException -> "bad_args"
        else -> "io_error"
    }

    // ── Picker ────────────────────────────────────────────────────────────────

    private fun pickTree(initialUri: String?, result: MethodChannel.Result) {
        val activity: Activity? = activityBinding?.activity
        if (activity == null) {
            result.error("no_activity", "Folder picker needs a foreground Activity", null)
            return
        }
        if (pendingPick != null) {
            result.error("busy", "A folder picker is already open", null)
            return
        }
        val intent = Intent(Intent.ACTION_OPEN_DOCUMENT_TREE).apply {
            addFlags(
                PERSIST_FLAGS or
                    Intent.FLAG_GRANT_PERSISTABLE_URI_PERMISSION or
                    Intent.FLAG_GRANT_PREFIX_URI_PERMISSION
            )
            if (initialUri != null && android.os.Build.VERSION.SDK_INT >= 26) {
                putExtra(DocumentsContract.EXTRA_INITIAL_URI, Uri.parse(initialUri))
            }
        }
        pendingPick = result
        try {
            activity.startActivityForResult(intent, REQUEST_PICK_TREE)
        } catch (t: Throwable) {
            pendingPick = null
            result.error("picker_failed", t.message, null)
        }
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?): Boolean {
        if (requestCode != REQUEST_PICK_TREE) return false
        val result = pendingPick ?: return true
        pendingPick = null
        val uri = if (resultCode == Activity.RESULT_OK) data?.data else null
        if (uri == null) {
            result.success(null)
            return true
        }
        try {
            context.contentResolver.takePersistableUriPermission(uri, PERSIST_FLAGS)
        } catch (t: Throwable) {
            result.error("persist_failed", t.message, null)
            return true
        }
        result.success(
            mapOf(
                "uri" to uri.toString(),
                "displayPath" to displayPathFor(uri),
            )
        )
        return true
    }

    private fun hasPersistedPermission(treeUri: Uri): Boolean {
        return context.contentResolver.persistedUriPermissions.any {
            it.uri == treeUri && it.isReadPermission && it.isWritePermission
        }
    }

    /**
     * Best-effort human-readable path for the picked tree. Only used for
     * display; every operation goes through the URI. For the platform
     * external-storage provider the document id is `<volume>:<relative>`;
     * other providers just get their document id.
     */
    private fun displayPathFor(treeUri: Uri): String {
        val docId = try {
            DocumentsContract.getTreeDocumentId(treeUri)
        } catch (_: Throwable) {
            return treeUri.toString()
        }
        if (treeUri.authority != EXTERNAL_STORAGE_AUTHORITY) return docId
        val sep = docId.indexOf(':')
        if (sep < 0) return docId
        val volume = docId.substring(0, sep)
        val relative = docId.substring(sep + 1).trimEnd('/')
        @Suppress("DEPRECATION")
        val root = if (volume == "primary") {
            Environment.getExternalStorageDirectory().absolutePath
        } else {
            "/storage/$volume"
        }
        return if (relative.isEmpty()) root else "$root/$relative"
    }

    // ── Document operations ───────────────────────────────────────────────────

    private val projection = arrayOf(
        DocumentsContract.Document.COLUMN_DOCUMENT_ID,
        DocumentsContract.Document.COLUMN_DISPLAY_NAME,
        DocumentsContract.Document.COLUMN_MIME_TYPE,
        DocumentsContract.Document.COLUMN_SIZE,
        DocumentsContract.Document.COLUMN_LAST_MODIFIED,
    )

    /** Direct (non-recursive) children of [treeUri] that are not directories. */
    private fun listChildren(treeUri: Uri): List<Map<String, Any?>> {
        val parentDocId = DocumentsContract.getTreeDocumentId(treeUri)
        val childrenUri =
            DocumentsContract.buildChildDocumentsUriUsingTree(treeUri, parentDocId)
        val out = ArrayList<Map<String, Any?>>()
        val cursor = context.contentResolver.query(childrenUri, projection, null, null, null)
            ?: throw SecurityException("Could not query $treeUri; the folder grant may have been revoked")
        cursor.use { c ->
            while (c.moveToNext()) {
                val mime = c.getString(2)
                if (mime == DocumentsContract.Document.MIME_TYPE_DIR) continue
                val docId = c.getString(0)
                val docUri = DocumentsContract.buildDocumentUriUsingTree(treeUri, docId)
                out.add(
                    mapOf(
                        "uri" to docUri.toString(),
                        "name" to (c.getString(1) ?: docId.substringAfterLast('/')),
                        "mimeType" to mime,
                        "size" to (if (c.isNull(3)) 0L else c.getLong(3)),
                        "lastModified" to (if (c.isNull(4)) 0L else c.getLong(4)),
                    )
                )
            }
        }
        return out
    }

    /** Metadata for one document, or null when it no longer exists. */
    private fun statDocument(documentUri: Uri): Map<String, Any?>? {
        val cursor = try {
            context.contentResolver.query(documentUri, projection, null, null, null)
        } catch (_: java.io.FileNotFoundException) {
            null
        } catch (e: IllegalArgumentException) {
            // Some providers surface a missing document as IAE("Unknown URI").
            null
        } ?: return null
        cursor.use { c ->
            if (!c.moveToFirst()) return null
            return mapOf(
                "uri" to documentUri.toString(),
                "name" to c.getString(1),
                "mimeType" to c.getString(2),
                "size" to (if (c.isNull(3)) 0L else c.getLong(3)),
                "lastModified" to (if (c.isNull(4)) 0L else c.getLong(4)),
            )
        }
    }

    /** Streams the document's bytes into [dest]; returns bytes written. */
    private fun copyToFile(documentUri: Uri, dest: File): Long {
        dest.parentFile?.mkdirs()
        val input = context.contentResolver.openInputStream(documentUri)
            ?: throw java.io.FileNotFoundException("Could not open $documentUri")
        var total = 0L
        input.use { src ->
            FileOutputStream(dest).use { sink ->
                val buf = ByteArray(256 * 1024)
                while (true) {
                    val n = src.read(buf)
                    if (n < 0) break
                    sink.write(buf, 0, n)
                    total += n
                }
                sink.fd.sync()
            }
        }
        return total
    }
}
