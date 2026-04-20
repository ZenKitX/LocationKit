import '../models/location_model.dart';

/// Location error types
enum LocationErrorType {
  permissionDenied,
  permissionPermanentlyDenied,
  serviceDisabled,
  timeout,
  unknown,
}

/// Location error
class LocationError {
  final LocationErrorType type;
  final String message;

  LocationError({
    required this.type,
    required this.message,
  });

  @override
  String toString() => 'LocationError: $type - $message';
}

/// Result type for location operations
class LocationResult<T> {
  final T? data;
  final LocationError? error;
  final bool isSuccess;

  LocationResult._({
    this.data,
    this.error,
    required this.isSuccess,
  });

  factory LocationResult.success(T data) {
    return LocationResult._(data: data, isSuccess: true);
  }

  factory LocationResult.failure(LocationError error) {
    return LocationResult._(error: error, isSuccess: false);
  }

  R fold<R>(
    R Function(T data) onSuccess,
    R Function(LocationError error) onFailure,
  ) {
    return isSuccess ? onSuccess(data as T) : onFailure(error!);
  }
}

/// Location service
///
/// Note: This is a mock implementation. In a real app, you would use
/// the `location` package (https://pub.dev/packages/location)
class LocationService {
  /// Get current location
  ///
  /// Note: This is a mock implementation that returns Beijing coordinates
  /// In production, replace with actual location package implementation
  Future<LocationResult<LocationData>> getCurrentLocation() async {
    try {
      // Simulate network delay
      await Future.delayed(const Duration(milliseconds: 500));

      // Mock location data (Beijing)
      final location = LocationData(
        latitude: 39.9042,
        longitude: 116.4074,
        city: 'Beijing',
        region: 'Beijing',
        country: 'China',
        address: 'Beijing, Beijing, China',
        timestamp: DateTime.now(),
      );

      return LocationResult.success(location);
    } catch (e) {
      return LocationResult.failure(
        LocationError(
          type: LocationErrorType.unknown,
          message: 'Failed to get location: ${e.toString()}',
        ),
      );
    }
  }

  /// Get last saved location
  Future<LocationData?> getLastLocation() async {
    // Mock implementation
    return null;
  }

  /// Save location
  Future<void> saveLocation(LocationData location) async {
    // Mock implementation
    await Future.delayed(const Duration(milliseconds: 100));
  }

  /// Check location permission
  Future<LocationResult<bool>> checkLocationPermission() async {
    try {
      // Mock: always return true
      await Future.delayed(const Duration(milliseconds: 100));
      return LocationResult.success(true);
    } catch (e) {
      return LocationResult.failure(
        LocationError(
          type: LocationErrorType.unknown,
          message: 'Failed to check permission: ${e.toString()}',
        ),
      );
    }
  }

  /// Request location permission
  Future<LocationResult<bool>> requestLocationPermission() async {
    try {
      // Mock: always return true
      await Future.delayed(const Duration(milliseconds: 200));
      return LocationResult.success(true);
    } catch (e) {
      return LocationResult.failure(
        LocationError(
          type: LocationErrorType.unknown,
          message: 'Failed to request permission: ${e.toString()}',
        ),
      );
    }
  }

  /// Get latitude and longitude
  Future<LocationResult<LatLong>> getLatLong() async {
    final result = await getCurrentLocation();
    return result.fold(
      (location) {
        if (location.hasCoordinates) {
          return LocationResult.success(
            LatLong(
              latitude: location.latitude!,
              longitude: location.longitude!,
            ),
          );
        } else {
          return LocationResult.failure(
            LocationError(
              type: LocationErrorType.unknown,
              message: 'Location does not have coordinates',
            ),
          );
        }
      },
      (error) => LocationResult.failure(error),
    );
  }

  /// Calculate distance between two locations
  double calculateDistance(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    final point1 = LatLong(latitude: lat1, longitude: lon1);
    final point2 = LatLong(latitude: lat2, longitude: lon2);
    return point1.distanceTo(point2);
  }
}
