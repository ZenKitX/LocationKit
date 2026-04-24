# LocationKit

A minimal location service package for Flutter apps, providing only basic functionality.

## Features

- ✅ **Minimal API** - Only the essential location functions
- ✅ **No Dependencies** - Zero external dependencies
- ✅ **Lightweight** - Small package size
- ✅ **Simple** - Easy to use and understand

## What LocationKit Provides

- Get current location (latitude, longitude, accuracy, timestamp)
- Calculate distance between two coordinates (Haversine formula)

## What LocationKit Does NOT Provide

- Permission handling (handle in your app layer)
- UI components (create your own location selector)
- Settings integration (handle in your app layer)
- Error dialogs (handle in your app layer)
- Stream updates (implement in your app layer if needed)

## Installation

Add `location_kit` to your `pubspec.yaml`:

```yaml
dependencies:
  location_kit: ^0.3.0
```

## Usage

### Get Current Location

**Note:** Make sure you have obtained location permissions before calling this method.

```dart
import 'package:location_kit/location_kit.dart';

try {
  final location = await LocationKit.getCurrentLocation();
  print('Latitude: ${location.latitude}');
  print('Longitude: ${location.longitude}');
  print('Accuracy: ${location.accuracy}m');
} on LocationException catch (e) {
  print('Failed to get location: ${e.message}');
  // Handle error in your app
}
```

### Calculate Distance

```dart
const beijing = LatLong(39.9042, 116.4074);
const shanghai = LatLong(31.2304, 121.4737);

final distance = LocationKit.calculateDistance(beijing, shanghai);
print('Distance: ${distance.toStringAsFixed(2)} meters');
```

## Application Layer Example

Here's how to handle permissions in your app:

```dart
import 'package:permission_handler/permission_handler.dart';

Future<LocationData> getLocationWithPermission() async {
  // Check permission
  final status = await Permission.location.status;

  // Request permission if needed
  if (!status.isGranted) {
    final result = await Permission.location.request();
    if (!result.isGranted) {
      throw Exception('Permission denied');
    }
  }

  // Get location
  return await LocationKit.getCurrentLocation();
}
```

## Models

### LocationData

Basic location data:

```dart
class LocationData {
  final double latitude;
  final double longitude;
  final DateTime timestamp;
  final double accuracy;
}
```

### LatLong

Geographic coordinate:

```dart
class LatLong {
  final double latitude;
  final double longitude;
}
```

## Platform Configuration

### Android

Add to `android/app/src/main/AndroidManifest.xml`:

```xml
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
```

### iOS

Add to `ios/Runner/Info.plist`:

```xml
<key>NSLocationWhenInUseUsageDescription</key>
<string>This app needs access to location.</string>
```

## Platform Channel Implementation

**Note:** The `getCurrentLocation()` method requires platform channel implementation.

To implement:

1. Create Android platform channel handler
2. Create iOS platform channel handler
3. Call native location services
4. Return location data

Example for Android (Kotlin):

```kotlin
// MainActivity.kt
MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "location_kit")
  .setMethodCallHandler { call, result ->
    if (call.method == "getCurrentLocation") {
      // Implement location retrieval
      // Return: {latitude, longitude, accuracy, timestamp}
    }
  }
```

## License

MIT License
