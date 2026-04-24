package com.zenkit.location_kit

import androidx.annotation.NonNull
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodChannel
import java.text.SimpleDateFormat
import java.util.Date

/// LocationKit Android Plugin with activity awareness
class LocationKitPlugin : FlutterPlugin, ActivityAware {
    override fun onAttachedToEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
        // Platform channel implementation
        val channel = MethodChannel(binding.binaryMessenger, "location_kit")
        channel.setMethodCallHandler { call, result ->
            if (call.method == "getCurrentLocation") {
                // Return mock data for now
                result.success(mapOf(
                    "latitude" to 39.9042,
                    "longitude" to 116.4074,
                    "accuracy" to 10.0,
                    "timestamp" to SimpleDateFormat("yyyy-MM-dd'T'HH:mm:ss.SSS").format(Date())
                ))
            } else {
                result.notImplemented()
            }
        }
    }

    override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {}

    override fun onAttachedToActivity(@NonNull binding: ActivityPluginBinding) {}

    override fun onDetachedFromActivity() {}

    override fun onDetachedFromActivityForConfigChanges() {}

    override fun onReattachedToActivityForConfigChanges(@NonNull binding: ActivityPluginBinding) {}
}
