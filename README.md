# LocationKit

A powerful location service package for Flutter applications, built on top of the reliable [Geolocator](https://github.com/Baseflow/flutter-geolocator) library.

## Features

- ✅ **GPS Positioning** - Get current location with high accuracy
- ✅ **Permission Handling** - Easy permission request and checking
- ✅ **Location Streaming** - Real-time location updates
- ✅ **Distance Calculation** - Calculate distances between coordinates
- ✅ **Bearing Calculation** - Calculate heading between points
- ✅ **Settings Integration** - Direct links to app/location settings
- ✅ **Result Type** - Safe error handling with Result type
- ✅ **Cross-Platform** - Android, iOS, Web, macOS, Linux, Windows

## Installation

Add `location_kit` to your `pubspec.yaml`:

```yaml
dependencies:
  location_kit: ^0.2.0
```

## Usage

### Get Current Location

```dart
import 'package:location_kit/location_kit.dart';

void main() async {
  final result = await LocationKit.getCurrentLocation();

  result.fold(
    (location) {
      print('Latitude: ${location.latitude}');
      print('Longitude: ${location.longitude}');
      print('Accuracy: ${location.accuracy}m');
    },
    (error) {
      print('Error: ${error.message}');
    },
  );
}
```

### Request Permission

```dart
final result = await LocationKit.checkPermission();

result.fold(
  (permission) {
    if (!permission.isGranted) {
      final requestResult = await LocationKit.requestPermission();
      requestResult.fold(
        (newPermission) => print('Permission: $newPermission'),
        (error) => print('Error: ${error.message}'),
      );
    }
  },
  (error) => print('Error: ${error.message}'),
);
```

### Stream Location Updates

```dart
final stream = LocationKit.getLocationStream();

stream.listen(
  (result) {
    result.fold(
      (location) => print('Updated: ${location.latitude}, ${location.longitude}'),
      (error) => print('Error: ${error.message}'),
    );
  },
);
```

### Calculate Distance

```dart
const beijing = LatLong(39.9042, 116.4074);
const shanghai = LatLong(31.2304, 121.4737);

final distance = LocationKit.calculateDistance(beijing, shanghai);
print('Distance: ${distance.toStringAsFixed(2)} meters');
```

### Open Settings

```dart
// Open app settings to change permissions
await LocationKit.openAppSettings();

// Open device location settings
await LocationKit.openLocationSettings();
```

## Error Handling

LocationKit uses a `Result<T>` type for safe error handling:

```dart
final result = await LocationKit.getCurrentLocation();

if (result.isSuccess) {
  final location = result.data;
  // Use location
} else {
  final error = result.error;
  // Handle error
  switch (error.type) {
    case LocationErrorType.permissionDenied:
      // Request permission
      break;
    case LocationErrorType.serviceDisabled:
      // Ask user to enable location service
      break;
    case LocationErrorType.permissionPermanentlyDenied:
      // Guide user to app settings
      await LocationKit.openAppSettings();
      break;
    default:
      // Handle other errors
      break;
  }
}
```

## Models

### LocationData

Represents location data with all available information:

```dart
class LocationData {
  final double latitude;
  final double longitude;
  final DateTime timestamp;
  final double altitude;
  final double accuracy;
  final double speed;
  final double heading;
  // ... more fields
}
```

### LocationPermission

Represents the permission status:

```dart
enum LocationPermission {
  denied,
  deniedForever,
  whileInUse,
  always,
  unknown,
}
```

### LocationError

Represents location-related errors:

```dart
enum LocationErrorType {
  permissionDenied,
  permissionPermanentlyDenied,
  serviceDisabled,
  timeout,
  unknown,
}
```

## API Reference

### Static Methods

| Method | Description | Returns |
|--------|-------------|---------|
| `getCurrentLocation()` | Get current location | `Result<LocationData>` |
| `getLastKnownPosition()` | Get last known position | `Result<LocationData?>` |
| `isLocationServiceEnabled()` | Check if service is enabled | `Result<bool>` |
| `checkPermission()` | Check permission status | `Result<LocationPermission>` |
| `requestPermission()` | Request permission | `Result<LocationPermission>` |
| `getLocationStream()` | Stream location updates | `Stream<Result<LocationData>>` |
| `calculateDistance()` | Calculate distance | `double` |
| `calculateBearing()` | Calculate bearing | `double` |
| `openAppSettings()` | Open app settings | `Result<void>` |
| `openLocationSettings()` | Open location settings | `Result<void>` |

## Platform-Specific Configuration

### Android

Add to `android/app/src/main/AndroidManifest.xml`:

```xml
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />

<uses-feature android:name="android.hardware.location.gps" />
```

### iOS

Add to `ios/Runner/Info.plist`:

```xml
<key>NSLocationWhenInUseUsageDescription</key>
<string>This app needs access to location when in use.</string>

<key>NSLocationAlwaysAndWhenInUseUsageDescription</key>
<string>This app needs access to location always.</string>
```

## Dependencies

- [Geolocator](https://pub.dev/packages/geolocator) ^11.0.0
- [Permission Handler](https://pub.dev/packages/permission_handler) ^11.0.0

## License

MIT License

## Credits

Built on top of [Geolocator](https://github.com/Baseflow/flutter-geolocator) by Baseflow.
