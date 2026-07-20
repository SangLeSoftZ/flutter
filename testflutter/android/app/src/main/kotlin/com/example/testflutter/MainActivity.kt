package com.example.testflutter

import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.os.BatteryManager
import android.os.Build
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

// ══════════════════════════════════════════════════════════════════
// Platform Channel — Android (Kotlin)
// Tuần 3 Ngày 4 (Sáng)
//
// Tên kênh PHẢI khớp với Dart: "com.example.testflutter/battery"
// setMethodCallHandler: nhận mọi invokeMethod từ Flutter
// call.method: tên method Flutter gọi
// result.success(...): trả kết quả về Flutter
// result.notImplemented(): method không có → PlatformException(not_implemented)
// ══════════════════════════════════════════════════════════════════
class MainActivity : FlutterActivity() {

    // Tên kênh phải khớp CHÍNH XÁC với Dart
    private val CHANNEL = "com.example.testflutter/battery"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    // Bài 1: trả mức pin thực tế
                    "getBatteryLevel" -> {
                        val mucPin = layMucPin()
                        if (mucPin != -1) {
                            result.success(mucPin)
                        } else {
                            result.error(
                                "UNAVAILABLE",
                                "Không lấy được mức pin",
                                null
                            )
                        }
                    }
                    // Demo thêm: trả thông tin thiết bị
                    "getDeviceInfo" -> {
                        val info = "Thiết bị: ${Build.MANUFACTURER} ${Build.MODEL}\n" +
                                "Android: ${Build.VERSION.RELEASE} (API ${Build.VERSION.SDK_INT})"
                        result.success(info)
                    }
                    // Bài 2: method không có → Flutter nhận PlatformException(not_implemented)
                    // Khi call.method không khớp case nào → result.notImplemented()
                    else -> result.notImplemented()
                }
            }
    }

    private fun layMucPin(): Int {
        return if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
            val batteryManager = getSystemService(Context.BATTERY_SERVICE) as BatteryManager
            batteryManager.getIntProperty(BatteryManager.BATTERY_PROPERTY_CAPACITY)
        } else {
            // Fallback cho Android cũ
            val intent = registerReceiver(
                null,
                IntentFilter(Intent.ACTION_BATTERY_CHANGED)
            )
            val level = intent?.getIntExtra(BatteryManager.EXTRA_LEVEL, -1) ?: -1
            val scale = intent?.getIntExtra(BatteryManager.EXTRA_SCALE, -1) ?: -1
            if (level == -1 || scale == -1) -1
            else (level * 100 / scale.toFloat()).toInt()
        }
    }
}
