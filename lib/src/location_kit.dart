import 'dart:async';
import 'package:geolocator/geolocator.dart' as geo;
import 'models/location_data.dart';
import 'models/location_permission.dart';
import 'models/lat_long.dart';
import 'errors/location_errors.dart';

/// LocationKit - A location service package for Flutter apps
///
/// Provides:
/// - GPS positioning
/// - Location management
/// - Permission handling
/// - Distance calculation
///
/// Built on top of [Geolocator] for reliable cross-platform support.
///
/// Usage:
/// ```dart
/// final result = await LocationKit.getCurrentLocation();
/// if (result.isSuccess) {
///   final location = result.data;
///   print('Lat: ${location.latitude}, Lng: ${location.longitude}');
/// }
/// ```
class LocationKit {
  LocationKit._();

  /// Get the current location of the device.
  ///
  /// Returns a [Result] containing either [LocationData] or [LocationError].
  ///
  /// Example:
  /// ```dart
  /// final result = await LocationKit.getCurrentLocation();
  /// result.fold(
  ///   (location) => print('Got location: ${location.latitude}'),
  ///   (error) => print('Error: ${error.message}'),
  /// );
  /// ```
  static Future<Result<LocationData>> getCurrentLocation({
    geo.LocationSettings? settings,
  }) async {
    try {
      // Check if location service is enabled
      final serviceEnabled = await geo.Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return Result.failure(
          LocationError.serviceDisabled(
            'Location services are disabled. Please enable them in settings.',
          ),
        );
      }

      // Check permission
      geo.LocationPermission permission =
          await geo.Geolocator.checkPermission();
      if (permission == geo.LocationPermission.denied) {
        permission = await geo.Geolocator.requestPermission();
        if (permission == geo.LocationPermission.denied) {
          return Result.failure(
            LocationError.permissionDenied(
              'Location permission denied.',
            ),
          );
        }
      }

      if (permission == geo.LocationPermission.deniedForever) {
        return Result.failure(
          LocationError.permissionPermanentlyDenied(
            'Location permission permanently denied. '
            'Please enable it in app settings.',
          ),
        );
      }

      // Get current position
      final position = await geo.Geolocator.getCurrentPosition(
        locationSettings: settings ??
            const geo.LocationSettings(
              accuracy: geo.LocationAccuracy.best,
            ),
      );

      return Result.success(_convertPosition(position));
    } on TimeoutException {
      return Result.failure(
        LocationError.timeout('Location request timed out.'),
      );
    } on geo.LocationServiceDisabledException catch (e) {
      return Result.failure(
        LocationError.serviceDisabled(e.message),
      );
    } on Exception catch (e) {
      return Result.failure(
        LocationError.unknown('Failed to get location: $e'),
      );
    }
  }

  /// Get the last known position stored on the device.
  ///
  /// Returns null if no position is available.
  static Future<Result<LocationData?>> getLastKnownPosition({
    bool forceLocationManager = false,
  }) async {
    try {
      final position = await geo.Geolocator.getLastKnownPosition(
        forceLocationManager: forceLocationManager,
      );
      return Result.success(position != null ? _convertPosition(position) : null);
    } on Exception catch (e) {
      return Result.failure(
        LocationError.unknown('Failed to get last known position: $e'),
      );
    }
  }

  /// Check if location services are enabled on the device.
  static Future<Result<bool>> isLocationServiceEnabled() async {
    try {
      final enabled = await geo.Geolocator.isLocationServiceEnabled();
      return Result.success(enabled);
    } on Exception catch (e) {
      return Result.failure(
        LocationError.unknown('Failed to check location service: $e'),
      );
    }
  }

  /// Check the current location permission status.
  static Future<Result<LocationPermission>> checkPermission() async {
    try {
      final permission = await geo.Geolocator.checkPermission();
      return Result.success(_convertPermission(permission));
    } on Exception catch (e) {
      return Result.failure(
        LocationError.unknown('Failed to check permission: $e'),
      );
    }
  }

  /// Request location permission from the user.
  static Future<Result<LocationPermission>> requestPermission() async {
    try {
      final permission = await geo.Geolocator.requestPermission();
      return Result.success(_convertPermission(permission));
    } on Exception catch (e) {
      return Result.failure(
        LocationError.unknown('Failed to request permission: $e'),
      );
    }
  }

  /// Stream location updates.
  ///
  /// Returns a [Stream] of [Result] objects containing either
  /// [LocationData] or [LocationError].
  static Stream<Result<LocationData>> getLocationStream({
    geo.LocationSettings? settings,
  }) {
    final controller = StreamController<Result<LocationData>>();

    final subscription = geo.Geolocator.getPositionStream(
      locationSettings: settings ??
          const geo.LocationSettings(
            accuracy: geo.LocationAccuracy.best,
            distanceFilter: 10,
          ),
    ).listen(
      (position) {
        controller.add(Result.success(_convertPosition(position)));
      },
      onError: (error) {
        controller.add(
          Result.failure(
            LocationError.unknown('Location stream error: $error'),
          ),
        );
      },
    );

    controller.onCancel = () => subscription.cancel();

    return controller.stream;
  }

  /// Calculate the distance between two coordinates in meters.
  ///
  /// Uses the Haversine formula.
  static double calculateDistance(LatLong start, LatLong end) {
    return geo.Geolocator.distanceBetween(
      start.latitude,
      start.longitude,
      end.latitude,
      end.longitude,
    );
  }

  /// Calculate the bearing between two coordinates in degrees.
  static double calculateBearing(LatLong start, LatLong end) {
    return geo.Geolocator.bearingBetween(
      start.latitude,
      start.longitude,
      end.latitude,
      end.longitude,
    );
  }

  /// Open app settings so the user can enable location services.
  static Future<Result<void>> openAppSettings() async {
    try {
      await geo.Geolocator.openAppSettings();
      return Result.success(null);
    } on Exception catch (e) {
      return Result.failure(
        LocationError.unknown('Failed to open app settings: $e'),
      );
    }
  }

  /// Open location settings so the user can enable location services.
  static Future<Result<void>> openLocationSettings() async {
    try {
      await geo.Geolocator.openLocationSettings();
      return Result.success(null);
    } on Exception catch (e) {
      return Result.failure(
        LocationError.unknown('Failed to open location settings: $e'),
      );
    }
  }

  // Convert Geolocator Position to LocationKit LocationData
  static LocationData _convertPosition(geo.Position position) {
    return LocationData(
      latitude: position.latitude,
      longitude: position.longitude,
      altitude: position.altitude,
      accuracy: position.accuracy,
      timestamp: position.timestamp,
      speed: position.speed,
      heading: position.heading,
      altitudeAccuracy: position.altitudeAccuracy,
      headingAccuracy: position.headingAccuracy,
      speedAccuracy: position.speedAccuracy,
      isMocked: position.isMocked,
    );
  }

  // Convert Geolocator LocationPermission to LocationKit LocationPermission
  static LocationPermission _convertPermission(
    geo.LocationPermission permission,
  ) {
    return LocationPermission.values.firstWhere(
      (p) => p.name == permission.name,
      orElse: () => LocationPermission.denied,
    );
  }
}
