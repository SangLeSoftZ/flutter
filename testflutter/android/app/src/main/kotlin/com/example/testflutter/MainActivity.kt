package com.example.testflutter

import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.os.BatteryManager
import android.os.Build
import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

// ══════════════════════════════════════════════════════════════════
// Platform Channel — Android (Kotlin)
// Tuần 3 Ngày 4 (Sáng)
//
// Tuần 4 Ngày 1: doi FlutterActivity -> FlutterFragmentActivity
//   local_auth yeu cau FlutterFragmentActivity vi BiometricPrompt
//   can FragmentActivity lam nen de hien hop thoai sinh trac hoc
// ══════════════════════════════════════════════════════════════════
class MainActivity : FlutterFragmentActivity() {

    private val CHANNEL = "com.example.testflutter/battery"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "getBatteryLevel" -> {
                        val mucPin = layMucPin()
                        if (mucPin != -1) {
                            result.success(mucPin)
                        } else {
                            result.error("UNAVAILABLE", "Không lấy được mức pin", null)
                        }
                    }
                    "getDeviceInfo" -> {
                        val info = "Thiết bị: ${Build.MANUFACTURER} ${Build.MODEL}\n" +
                                "Android: ${Build.VERSION.RELEASE} (API ${Build.VERSION.SDK_INT})"
                        result.success(info)
                    }
                    else -> result.notImplemented()
                }
            }
    }

    private fun layMucPin(): Int {
        return if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
            val batteryManager = getSystemService(Context.BATTERY_SERVICE) as BatteryManager
            batteryManager.getIntProperty(BatteryManager.BATTERY_PROPERTY_CAPACITY)
        } else {
            val intent = registerReceiver(null, IntentFilter(Intent.ACTION_BATTERY_CHANGED))
            val level = intent?.getIntExtra(BatteryManager.EXTRA_LEVEL, -1) ?: -1
            val scale = intent?.getIntExtra(BatteryManager.EXTRA_SCALE, -1) ?: -1
            if (level == -1 || scale == -1) -1
            else (level * 100 / scale.toFloat()).toInt()
        }
    }
}
