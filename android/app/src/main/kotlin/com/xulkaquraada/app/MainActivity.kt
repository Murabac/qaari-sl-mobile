package com.xulkaquraada.app

import android.graphics.Color
import android.os.Bundle
import androidx.core.view.WindowCompat
import com.ryanheise.audioservice.AudioServiceActivity

class MainActivity : AudioServiceActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        window.statusBarColor = Color.WHITE
        WindowCompat.getInsetsController(window, window.decorView)
            .isAppearanceLightStatusBars = true
    }
}
