/// Represents basic location data.
class LocationData {
  const LocationData({
    required this.latitude,
    required this.longitude,
    required this.timestamp,
    this.accuracy = 0.0,
  });

  /// Latitude in degrees (between -90 and 90).
  final double latitude;

  /// Longitude in degrees (between -180 and 180).
  final double longitude;

  /// Timestamp when the location was determined.
  final DateTime timestamp;

  /// Estimated horizontal accuracy in meters.
  final double accuracy;

  /// Returns the location as a LatLong object.
  LatLong toLatLong() => LatLong(latitude, longitude);

  @override
  String toString() {
    return 'LocationData(lat: $latitude, lng: $longitude, '
        'accuracy: ${accuracy}m, time: $timestamp)';
  }
}
