import 'dart:math';
import 'models/location_data.dart';
import 'models/lat_long.dart';

/// LocationKit - Minimal location service for Flutter apps
///
/// Provides only basic location functionality:
/// - Get current location
/// - Calculate distance between points
///
/// Permission handling, error dialogs, and UI are handled by the application layer.
///
/// Note: Before calling getCurrentLocation(), make sure you have
/// obtained location permissions from the user.
class LocationKit {
  LocationKit._();

  /// Get the current location of the device.
  ///
  /// Returns [LocationData] with latitude, longitude, accuracy, and timestamp.
  ///
  /// Throws [LocationException] if:
  /// - Location service is disabled
  /// - Permission is denied
  /// - Location cannot be determined
  ///
  /// Usage:
  /// ```dart
  /// try {
  ///   final location = await LocationKit.getCurrentLocation();
  ///   print('Lat: ${location.latitude}, Lng: ${location.longitude}');
  /// } on LocationException catch (e) {
  ///   print('Failed: ${e.message}');
  /// }
  /// ```
  static Future<LocationData> getCurrentLocation() async {
    // TODO: Implement platform channel call to native location service
    // For now, throw an exception to indicate not implemented
    throw const LocationException(
      'LocationKit is not yet implemented. '
      'This requires platform channel implementation for Android/iOS.',
    );
  }

  /// Calculate the distance between two coordinates in meters.
  ///
  /// Uses the Haversine formula.
  ///
  /// [start] - Starting coordinate
  /// [end] - Ending coordinate
  ///
  /// Returns distance in meters.
  ///
  /// Usage:
  /// ```dart
  /// final beijing = const LatLong(39.9042, 116.4074);
  /// final shanghai = const LatLong(31.2304, 121.4737);
  /// final distance = LocationKit.calculateDistance(beijing, shanghai);
  /// print('Distance: ${distance.toStringAsFixed(2)} meters');
  /// ```
  static double calculateDistance(LatLong start, LatLong end) {
    const double earthRadius = 6371000; // Earth's radius in meters

    final lat1Rad = _degreesToRadians(start.latitude);
    final lat2Rad = _degreesToRadians(end.latitude);
    final deltaLatRad = _degreesToRadians(end.latitude - start.latitude);
    final deltaLonRad = _degreesToRadians(end.longitude - start.longitude);

    final a = sin(deltaLatRad / 2) * sin(deltaLatRad / 2) +
        cos(lat1Rad) *
            cos(lat2Rad) *
            sin(deltaLonRad / 2) *
            sin(deltaLonRad / 2);

    final c = 2 * atan2(sqrt(a), sqrt(1 - a));

    return earthRadius * c;
  }

  /// Convert degrees to radians.
  static double _degreesToRadians(double degrees) {
    return degrees * pi / 180;
  }
}

/// Location exception thrown when location operations fail.
class LocationException implements Exception {
  const LocationException(this.message);

  /// Error message.
  final String message;

  @override
  String toString() => 'LocationException: $message';
}
