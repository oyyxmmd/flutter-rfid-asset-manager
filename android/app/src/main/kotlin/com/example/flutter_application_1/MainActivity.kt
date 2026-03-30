package com.example.flutter_application_1

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import com.example.flutter_application_1.rfid.UrovoDirectRfidBridge

class MainActivity : FlutterActivity() {
    private lateinit var urovoDirectRfidBridge: UrovoDirectRfidBridge

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        urovoDirectRfidBridge = UrovoDirectRfidBridge(
            context = applicationContext,
            messenger = flutterEngine.dartExecutor.binaryMessenger,
        )
    }

    override fun onDestroy() {
        if (::urovoDirectRfidBridge.isInitialized) {
            urovoDirectRfidBridge.dispose()
        }
        super.onDestroy()
    }
}
