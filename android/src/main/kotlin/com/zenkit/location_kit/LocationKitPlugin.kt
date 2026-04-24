package com.zenkit.location_kit

import android.Manifest
import android.content.Context
import android.content.pm.PackageManager
import android.location.Location
import android.location.LocationListener
import android.location.LocationManager
import android.os.Bundle
import android.os.Handler
import android.os.Looper
import androidx.core.app.ActivityCompat
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result

/**
 * LocationKit Plugin
 *
 * Provides minimal location functionality using Android LocationManager.
 * Reference: Simplified from Geolocator (MIT license)
 */
class LocationKitPlugin : FlutterPlugin, MethodCallHandler {
    private lateinit var channel: MethodChannel
    private lateinit var context: Context
    private lateinit var locationManager: LocationManager
    private val handler = Handler(Looper.getMainLooper())

    companion object {
        private const val TAG = "LocationKitPlugin"
        private const val METHOD_GET_CURRENT_LOCATION = "getCurrentLocation"
        private const val ERROR_PERMISSION_DENIED = "PERMISSION_DENIED"
        private const val ERROR_LOCATION_DISABLED = "LOCATION_DISABLED"
        private const val ERROR_TIMEOUT = "TIMEOUT"
        private const val ERROR_NO_LOCATION = "NO_LOCATION"
        private const val TIMEOUT_MS = 30000L // 30 seconds timeout
    }

    override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        channel = MethodChannel(flutterPluginBinding.binaryMessenger, "location_kit")
        channel.setMethodCallHandler(this)
        context = flutterPluginBinding.applicationContext
        locationManager = context.getSystemService(Context.LOCATION_SERVICE) as LocationManager
    }

    override fun onMethodCall(call: MethodCall, result: Result) {
        when (call.method) {
            METHOD_GET_CURRENT_LOCATION -> getCurrentLocation(result)
            else -> result.notImplemented()
        }
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
    }

    private fun getCurrentLocation(result: Result) {
        // Check permissions
        if (!hasLocationPermission()) {
            result.error(
                ERROR_PERMISSION_DENIED,
                "Location permission not granted. Please request location permission before calling getCurrentLocation().",
                null
            )
            return
        }

        // Check if location service is enabled
        if (!isLocationServiceEnabled()) {
            result.error(
                ERROR_LOCATION_DISABLED,
                "Location service is disabled. Please enable location service in device settings.",
                null
            )
            return
        }

        // Get last known location first
        val lastKnownLocation = getLastKnownLocation()
        if (lastKnownLocation != null && isRecentLocation(lastKnownLocation)) {
            result.success(locationToMap(lastKnownLocation))
            return
        }

        // Request a fresh location update
        requestFreshLocation(result)
    }

    private fun hasLocationPermission(): Boolean {
        val coarsePermission = ActivityCompat.checkSelfPermission(
            context,
            Manifest.permission.ACCESS_COARSE_LOCATION
        ) == PackageManager.PERMISSION_GRANTED

        val finePermission = ActivityCompat.checkSelfPermission(
            context,
            Manifest.permission.ACCESS_FINE_LOCATION
        ) == PackageManager.PERMISSION_GRANTED

        return coarsePermission || finePermission
    }

    private fun isLocationServiceEnabled(): Boolean {
        return try {
            locationManager.isProviderEnabled(LocationManager.GPS_PROVIDER) ||
                    locationManager.isProviderEnabled(LocationManager.NETWORK_PROVIDER)
        } catch (e: Exception) {
            false
        }
    }

    private fun getLastKnownLocation(): Location? {
        return try {
            val providers = locationManager.getProviders(true)
            var bestLocation: Location? = null

            for (provider in providers) {
                val location = locationManager.getLastKnownLocation(provider)
                if (location != null) {
                    if (bestLocation == null || isBetterLocation(location, bestLocation)) {
                        bestLocation = location
                    }
                }
            }

            bestLocation
        } catch (e: Exception) {
            null
        }
    }

    private fun isRecentLocation(location: Location): Boolean {
        val age = System.currentTimeMillis() - location.time
        return age < 5 * 60 * 1000 // 5 minutes
    }

    private fun isBetterLocation(location: Location, currentBestLocation: Location?): Boolean {
        if (currentBestLocation == null) return true

        val timeDelta = location.time - currentBestLocation.time
        val isSignificantlyNewer = timeDelta > 2 * 60 * 1000 // 2 minutes
        val isSignificantlyOlder = timeDelta < -2 * 60 * 1000
        val isNewer = timeDelta > 0

        if (isSignificantlyNewer) return true
        if (isSignificantlyOlder) return false

        val accuracyDelta = location.accuracy - currentBestLocation.accuracy
        val isLessAccurate = accuracyDelta > 0
        val isMoreAccurate = accuracyDelta < 0

        if (isMoreAccurate) return true
        if (isNewer && !isLessAccurate) return true

        return false
    }

    private fun requestFreshLocation(result: Result) {
        val provider = selectBestProvider()
        if (provider == null) {
            result.error(
                ERROR_LOCATION_DISABLED,
                "No location provider is available",
                null
            )
            return
        }

        val locationListener = object : LocationListener {
            private var hasResult = false

            override fun onLocationChanged(location: Location) {
                if (hasResult) return
                hasResult = true

                handler.post {
                    try {
                        locationManager.removeUpdates(this)
                        result.success(locationToMap(location))
                    } catch (e: Exception) {
                        // Ignore if result was already sent
                    }
                }
            }

            override fun onProviderEnabled(provider: String) {}
            override fun onProviderDisabled(provider: String) {
                if (hasResult) return
                hasResult = true

                handler.post {
                    try {
                        locationManager.removeUpdates(this)
                        result.error(
                            ERROR_LOCATION_DISABLED,
                            "Location provider disabled",
                            null
                        )
                    } catch (e: Exception) {
                        // Ignore if result was already sent
                    }
                }
            }

            override fun onStatusChanged(provider: String?, status: Int, extras: Bundle?) {}
        }

        try {
            // Request location updates
            locationManager.requestLocationUpdates(
                provider,
                1000, // 1 second min time
                10f,  // 10 meters min distance
                locationListener
            )

            // Set timeout
            handler.postDelayed({
                if (!result.isResultSent()) {
                    try {
                        locationManager.removeUpdates(locationListener)
                        result.error(
                            ERROR_TIMEOUT,
                            "Location request timed out after $TIMEOUT_MS ms",
                            null
                        )
                    } catch (e: Exception) {
                        // Ignore
                    }
                }
            }, TIMEOUT_MS)
        } catch (e: Exception) {
            result.error(
                ERROR_NO_LOCATION,
                "Failed to request location: ${e.message}",
                null
            )
        }
    }

    private fun selectBestProvider(): String? {
        val providers = locationManager.getProviders(true)
        // Prefer GPS, then Network, then any available
        return when {
            providers.contains(LocationManager.GPS_PROVIDER) -> LocationManager.GPS_PROVIDER
            providers.contains(LocationManager.NETWORK_PROVIDER) -> LocationManager.NETWORK_PROVIDER
            providers.isNotEmpty() -> providers[0]
            else -> null
        }
    }

    private fun locationToMap(location: Location): Map<String, Any> {
        return mapOf(
            "latitude" to location.latitude,
            "longitude" to location.longitude,
            "accuracy" to location.accuracy.toDouble(),
            "timestamp" to android.text.format.DateFormat.format("yyyy-MM-dd'T'HH:mm:ss.SSS", location.time).toString()
        )
    }

    private fun Result.isResultSent(): Boolean {
        return try {
            javaClass.getMethod("isSent").invoke(this) as Boolean
        } catch (e: Exception) {
            false
        }
    }
}
