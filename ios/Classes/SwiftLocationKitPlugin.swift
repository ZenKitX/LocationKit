import Flutter
import CoreLocation

/// LocationKit Plugin for iOS
///
/// Provides minimal location functionality using CLLocationManager.
/// Reference: Simplified from Geolocator (MIT license)
public class SwiftLocationKitPlugin: NSObject, FlutterPlugin, CLLocationManagerDelegate {
    private var channel: FlutterMethodChannel?
    private var locationManager: CLLocationManager?
    private var result: FlutterResult?
    private var timeoutTimer: Timer?
    private var hasReceivedLocation = false

    private let methodGetCurrentLocation = "getCurrentLocation"
    private let errorPermissionDenied = "PERMISSION_DENIED"
    private let errorLocationDisabled = "LOCATION_DISABLED"
    private let errorTimeout = "TIMEOUT"
    private let errorNoLocation = "NO_LOCATION"
    private let timeoutInterval: TimeInterval = 30.0 // 30 seconds

    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "location_kit", binaryMessenger: registrar.messenger())
        let instance = SwiftLocationKitPlugin()
        instance.channel = channel
        instance.locationManager = CLLocationManager()
        instance.locationManager?.delegate = instance
        registrar.addMethodCallDelegate(instance, channel: channel)
    }

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case methodGetCurrentLocation:
            getCurrentLocation(result: result)
        default:
            result(FlutterMethodNotImplemented)
        }
    }

    private func getCurrentLocation(result: @escaping FlutterResult) {
        self.result = result
        self.hasReceivedLocation = false

        // Check permissions
        guard let locationManager = locationManager else {
            result(FlutterError(code: errorNoLocation, message: "LocationManager not initialized", details: nil))
            return
        }

        let authorizationStatus = locationManager.authorizationStatus

        switch authorizationStatus {
        case .authorizedWhenInUse, .authorizedAlways:
            break // Permission granted
        case .denied, .restricted:
            result(FlutterError(
                code: errorPermissionDenied,
                message: "Location permission denied. Please grant location permission in app settings.",
                details: nil
            ))
            return
        case .notDetermined:
            // Request permission
            locationManager.requestWhenInUseAuthorization()
            // Note: The result will be handled in locationManager(_:didChangeAuthorization:)
            return
        @unknown default:
            result(FlutterError(
                code: errorPermissionDenied,
                message: "Unknown authorization status",
                details: nil
            ))
            return
        }

        // Check if location service is enabled
        if !CLLocationManager.locationServicesEnabled() {
            result(FlutterError(
                code: errorLocationDisabled,
                message: "Location service is disabled. Please enable location service in device settings.",
                details: nil
            ))
            return
        }

        // Get last known location first
        if let lastLocation = locationManager.location, isRecentLocation(lastLocation) {
            result(locationToMap(lastLocation))
            return
        }

        // Request a fresh location update
        requestFreshLocation(locationManager: locationManager)
    }

    private func isRecentLocation(_ location: CLLocation) -> Bool {
        let age = Date().timeIntervalSince(location.timestamp)
        return age < 5 * 60 // 5 minutes
    }

    private func requestFreshLocation(locationManager: CLLocationManager) {
        // Configure location manager
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = 10.0 // 10 meters

        // Start location updates
        locationManager.startUpdatingLocation()

        // Set timeout
        timeoutTimer = Timer.scheduledTimer(withTimeInterval: timeoutInterval, repeats: false) { [weak self] _ in
            guard let self = self else { return }

            if !self.hasReceivedLocation, let result = self.result {
                locationManager.stopUpdatingLocation()
                result(FlutterError(
                    code: self.errorTimeout,
                    message: "Location request timed out after \(self.timeoutInterval) seconds",
                    details: nil
                ))
                self.result = nil
            }
        }
    }

    // MARK: - CLLocationManagerDelegate

    public func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard !hasReceivedLocation, let location = locations.last else {
            return
        }

        hasReceivedLocation = true

        // Stop location updates
        manager.stopUpdatingLocation()

        // Cancel timeout
        timeoutTimer?.invalidate()
        timeoutTimer = nil

        // Return location
        if let result = result {
            result(locationToMap(location))
            self.result = nil
        }
    }

    public func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        guard !hasReceivedLocation else { return }

        // Stop location updates
        manager.stopUpdatingLocation()

        // Cancel timeout
        timeoutTimer?.invalidate()
        timeoutTimer = nil

        // Return error
        if let result = result {
            let clError = error as? CLError
            let code = clError?.code.rawValue ?? -1

            switch code {
            case CLError.Code.denied.rawValue:
                result(FlutterError(
                    code: errorPermissionDenied,
                    message: "Location permission denied",
                    details: nil
                ))
            case CLError.Code.locationUnknown.rawValue:
                result(FlutterError(
                    code: errorNoLocation,
                    message: "Location could not be determined",
                    details: nil
                ))
            default:
                result(FlutterError(
                    code: errorNoLocation,
                    message: "Failed to get location: \(error.localizedDescription)",
                    details: nil
                ))
            }
            self.result = nil
        }
    }

    public func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        // If we're waiting for permission result
        if result != nil {
            switch status {
            case .authorizedWhenInUse, .authorizedAlways:
                // Permission granted, try again
                getCurrentLocation(result: result!)
            case .denied, .restricted:
                result?(FlutterError(
                    code: errorPermissionDenied,
                    message: "Location permission denied",
                    details: nil
                ))
                result = nil
            case .notDetermined:
                // Still waiting for user decision
                break
            @unknown default:
                result?(FlutterError(
                    code: errorPermissionDenied,
                    message: "Unknown authorization status",
                    details: nil
                ))
                result = nil
            }
        }
    }

    // MARK: - Helper Methods

    private func locationToMap(_ location: CLLocation) -> [String: Any] {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]

        return [
            "latitude": location.coordinate.latitude,
            "longitude": location.coordinate.longitude,
            "accuracy": location.horizontalAccuracy,
            "timestamp": formatter.string(from: location.timestamp)
        ]
    }
}
