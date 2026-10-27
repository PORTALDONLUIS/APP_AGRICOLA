package com.example.donluis_forms

import android.content.Intent
import android.hardware.camera2.CameraCharacteristics
import android.provider.MediaStore
import io.flutter.embedding.android.FlutterActivity

class MainActivity : FlutterActivity() {
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
