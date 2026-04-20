# LocationKit

A location service package for Flutter apps. Provides GPS positioning and location management.

## Features

- ✅ GPS positioning (mock implementation)
- ✅ Location management
- ✅ Permission handling
- ✅ Error handling with Result type
- ✅ Distance calculation
- ✅ Minimal dependencies

## Installation

Add this to your package's `pubspec.yaml` file:

```yaml
dependencies:
  location_kit:
    git:
      url: https://github.com/ZenKitX/LocationKit.git
      ref: main
```

## Usage

### Basic Usage

```dart
import 'package:location_kit/location_kit.dart';

void main() async {
  final locationService = LocationService();

  // Get current location
  final result = await locationService.getCurrentLocation();

  result.fold(
    (location) {
      print('Latitude: ${location.latitude}');
      print('Longitude: ${location.longitude}');
      print('City: ${location.city}');
      print('Address: ${location.formattedString}');
    },
    (error) {
      print('Error: ${error.message}');
    },
  );
}
```

### Get Coordinates

```dart
final result = await locationService.getLatLong();

result.fold(
  (latLong) {
    print('Latitude: ${latLong.latitude}');
    print('Longitude: ${latLong.longitude}');
  },
  (error) => print('Error: ${error.message}'),
);
```

### Permission Handling

```dart
// Check permission
final permissionCheck = await locationService.checkLocationPermission();

permissionCheck.fold(
  (hasPermission) {
    if (hasPermission) {
      print('Location permission granted');
    } else {
      print('Location permission denied');
    }
  },
  (error) => print('Error: ${error.message}'),
);

// Request permission
final permissionResult = await locationService.requestLocationPermission();
```

### Calculate Distance

```dart
final distance = locationService.calculateDistance(
  39.9042, // Beijing lat
  116.4074, // Beijing lon
  31.2304, // Shanghai lat
  121.4737, // Shanghai lon
);

print('Distance: ${distance.toStringAsFixed(2)} km');
// Output: Distance: 1067.54 km
```

### Save and Load Location

```dart
// Save location
final location = LocationData(
  latitude: 39.9042,
  longitude: 116.4074,
  city: 'Beijing',
  region: 'Beijing',
  country: 'China',
);
await locationService.saveLocation(location);

// Load last saved location
final lastLocation = await locationService.getLastLocation();
if (lastLocation != null) {
  print('Last location: ${lastLocation.city}');
}
```

## Models

### LocationData

```dart
class LocationData {
  final double? latitude;
  final double? longitude;
  final String? city;
  final String? region;
  final String? country;
  final String? address;
  final DateTime? timestamp;

  bool get hasCoordinates;
  String get formattedString;
}
```

### LatLong

```dart
class LatLong {
  final double latitude;
  final double longitude;

  double distanceTo(LatLong other);
}
```

### LocationError

```dart
enum LocationErrorType {
  permissionDenied,
  permissionPermanentlyDenied,
  serviceDisabled,
  timeout,
  unknown,
}
```

## Error Handling

All operations return a `LocationResult<T>` type:

```dart
final result = await locationService.getCurrentLocation();

if (result.isSuccess) {
  final location = result.data!;
  // Use location
} else {
  final error = result.error!;
  // Handle error
}
```

Or use `fold`:

```dart
result.fold(
  (location) {
    // Success
  },
  (error) {
    // Failure
  },
);
```

## Note

This package provides a **mock implementation** for demonstration purposes.

In a production app, you should:
1. Add the `location` package to `pubspec.yaml`:
   ```yaml
   dependencies:
     location: ^5.0.3
   ```
2. Implement actual GPS positioning
3. Handle real permission requests
4. Use platform-specific location services

## Example Integration

```dart
import 'package:location/location.dart';

class RealLocationService {
  final Location _location = Location();

  Future<LocationResult<LocationData>> getCurrentLocation() async {
    try {
      final serviceEnabled = await _location.serviceEnabled();
      if (!serviceEnabled) {
        return LocationResult.failure(
          LocationError(
            type: LocationErrorType.serviceDisabled,
            message: 'Location services are disabled',
          ),
        );
      }

      final permission = await _location.hasPermission();
      if (permission == PermissionStatus.denied) {
        final requestResult = await _location.requestPermission();
        if (requestResult != PermissionStatus.granted) {
          return LocationResult.failure(
            LocationError(
              type: LocationErrorType.permissionDenied,
              message: 'Location permission denied',
            ),
          );
        }
      }

      final locationData = await _location.getLocation();
      return LocationResult.success(
        LocationData(
          latitude: locationData.latitude,
          longitude: locationData.longitude,
          timestamp: DateTime.now(),
        ),
      );
    } catch (e) {
      return LocationResult.failure(
        LocationError(
          type: LocationErrorType.unknown,
          message: e.toString(),
        ),
      );
    }
  }
}
```

## License

MIT License

## Contributing

Contributions are welcome! Please feel free to:
- Implement real GPS positioning
- Add more features
- Fix bugs
- Improve documentation
