import Flutter
import CoreLocation

/// LocationKit iOS Plugin
public class LocationKitPlugin: NSObject, FlutterPlugin {
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(
            name: "location_kit",
            binaryMessenger: registrar.messenger()
        )
        let instance = LocationKitPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
    }

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        if call.method == "getCurrentLocation" {
            // Return mock data for now
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS"
            
            let locationData: [String: Any] = [
                "latitude": 39.9042,
                "longitude": 116.4074,
                "accuracy": 10.0,
                "timestamp": dateFormatter.string(from: Date())
            ]
            
            result(locationData)
        } else {
            result(FlutterMethodNotImplemented)
        }
    }
}
