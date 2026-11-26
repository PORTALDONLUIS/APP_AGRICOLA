package com.example.donluis_forms

import android.app.Activity
import android.content.Intent
import android.hardware.camera2.CameraCharacteristics
import android.net.Uri
import android.provider.MediaStore
import android.provider.OpenableColumns
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.File
import java.io.FileOutputStream

class MainActivity : FlutterActivity() {
    companion object {
        private const val TIC_FILES_CHANNEL = "dontec/tic_files"
        private const val PICK_PDF_REQUEST_CODE = 9401
        private const val MAX_PDF_BYTES = 15L * 1024L * 1024L
    }

    private var pendingPdfResult: MethodChannel.Result? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, TIC_FILES_CHANNEL)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "pickPdf" -> launchPdfPicker(result)
                    else -> result.notImplemented()
                }
            }
    }

    @Suppress("DEPRECATION")
    private fun launchPdfPicker(result: MethodChannel.Result) {
        if (pendingPdfResult != null) {
            result.error("BUSY", "Ya hay una selección de documento en curso.", null)
            return
        }
        pendingPdfResult = result
        try {
            val intent = Intent(Intent.ACTION_OPEN_DOCUMENT).apply {
                addCategory(Intent.CATEGORY_OPENABLE)
                type = "application/pdf"
                putExtra(Intent.EXTRA_MIME_TYPES, arrayOf("application/pdf"))
            }
            startActivityForResult(intent, PICK_PDF_REQUEST_CODE)
        } catch (_: Exception) {
            pendingPdfResult = null
            result.error(
                "NO_PICKER",
                "No se encontró un selector de archivos PDF en este dispositivo.",
                null
            )
        }
    }

    @Suppress("DEPRECATION")
    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        if (requestCode == PICK_PDF_REQUEST_CODE) {
            val callback = pendingPdfResult
            pendingPdfResult = null
            if (callback == null) return
            if (resultCode != Activity.RESULT_OK || data?.data == null) {
                callback.success(null)
                return
            }
            copySelectedPdf(data.data!!, callback)
            return
        }
        super.onActivityResult(requestCode, resultCode, data)
    }

    private fun copySelectedPdf(uri: Uri, callback: MethodChannel.Result) {
        var outFile: File? = null
        try {
            var displayName = "denuncia.pdf"
            contentResolver.query(uri, arrayOf(OpenableColumns.DISPLAY_NAME), null, null, null)
                ?.use { cursor ->
                    if (cursor.moveToFirst()) {
                        val idx = cursor.getColumnIndex(OpenableColumns.DISPLAY_NAME)
                        if (idx >= 0) {
                            val candidate = cursor.getString(idx)?.trim()
                            if (!candidate.isNullOrEmpty()) {
                                displayName = candidate
                            }
                        }
                    }
                }
            val safeBase = displayName
                .replace(Regex("[^a-zA-Z0-9._-]+"), "_")
                .trim('_', '.')
                .ifEmpty { "denuncia.pdf" }
            val safeName = if (safeBase.lowercase().endsWith(".pdf")) safeBase else "$safeBase.pdf"
            outFile = File(cacheDir, "tic_pdf_${System.currentTimeMillis()}_$safeName")

            var totalBytes = 0L
            val header = ByteArray(5)
            var headerRead = 0
            val input = contentResolver.openInputStream(uri)
                ?: throw IllegalStateException("No se pudo abrir el archivo seleccionado.")
            input.use { stream ->
                FileOutputStream(outFile).use { output ->
                    val buffer = ByteArray(16 * 1024)
                    while (true) {
                        val read = stream.read(buffer)
                        if (read <= 0) break
                        if (headerRead < 5) {
                            val take = minOf(5 - headerRead, read)
                            System.arraycopy(buffer, 0, header, headerRead, take)
                            headerRead += take
                        }
                        totalBytes += read
                        if (totalBytes > MAX_PDF_BYTES) {
                            outFile.delete()
                            callback.error(
                                "TOO_LARGE",
                                "El documento PDF admite hasta 15 MB.",
                                null
                            )
                            return
                        }
                        output.write(buffer, 0, read)
                    }
                    output.flush()
                }
            }
            if (headerRead < 5 || String(header, Charsets.US_ASCII) != "%PDF-") {
                outFile.delete()
                callback.error(
                    "INVALID_PDF",
                    "Solo se admiten archivos en formato PDF válido.",
                    null
                )
                return
            }
            callback.success(
                mapOf(
                    "path" to outFile.absolutePath,
                    "name" to displayName,
                    "size" to totalBytes
                )
            )
        } catch (_: Exception) {
            outFile?.delete()
            callback.error(
                "READ_ERROR",
                "No se pudo leer el archivo PDF seleccionado.",
                null
            )
        }
    }

    @Suppress("DEPRECATION")
    override fun startActivityForResult(intent: Intent, requestCode: Int) {
        // image_picker adds lens extras only for FRONT. Some camera apps otherwise
        // reopen their last lens; preserve explicit front requests from the plugin.
        if (intent.action == MediaStore.ACTION_IMAGE_CAPTURE &&
            !intent.hasExtra("android.intent.extras.CAMERA_FACING") &&
            !intent.hasExtra("android.intent.extra.USE_FRONT_CAMERA")) {
            intent.putExtra("android.intent.extras.CAMERA_FACING", CameraCharacteristics.LENS_FACING_BACK)
            intent.putExtra("android.intent.extras.LENS_FACING_BACK", CameraCharacteristics.LENS_FACING_BACK)
            intent.putExtra("android.intent.extra.USE_FRONT_CAMERA", false)
        }
        // Keep the plugin's output URI, grants, request code and result handling.
        super.startActivityForResult(intent, requestCode)
    }
}
