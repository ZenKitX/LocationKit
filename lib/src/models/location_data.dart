/// Represents location data with geographical coordinates and additional information.
class LocationData {
  const LocationData({
    required this.latitude,
    required this.longitude,
    required this.timestamp,
    this.altitude = 0.0,
    this.accuracy = 0.0,
    this.altitudeAccuracy = 0.0,
    this.speed = 0.0,
    this.heading = 0.0,
    this.speedAccuracy = 0.0,
    this.headingAccuracy = 0.0,
    this.isMocked = false,
  });

  /// Latitude in degrees (between -90 and 90).
  final double latitude;

  /// Longitude in degrees (between -180 and 180).
  final double longitude;

  /// Timestamp when the location was determined.
  final DateTime timestamp;

  /// Altitude in meters above sea level.
  final double altitude;

  /// Estimated horizontal accuracy in meters.
  final double accuracy;

  /// Estimated vertical accuracy in meters.
  final double altitudeAccuracy;

  /// Speed in meters per second.
  final double speed;

  /// Heading in degrees (0-360, 0 = North).
  final double heading;

  /// Estimated speed accuracy in meters per second.
  final double speedAccuracy;

  /// Estimated heading accuracy in degrees.
  final double headingAccuracy;

  /// True if the location is mocked/simulated.
  final bool isMocked;

  /// Returns the location as a LatLong object.
  LatLong toLatLong() => LatLong(latitude, longitude);

  @override
  String toString() {
    return 'LocationData(lat: $latitude, lng: $longitude, '
        'accuracy: ${accuracy}m, time: $timestamp)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is LocationData &&
        other.latitude == latitude &&
        other.longitude == longitude &&
        other.timestamp == timestamp &&
        other.altitude == altitude &&
        other.accuracy == accuracy &&
        other.isMocked == isMocked;
  }

  @override
  int get hashCode {
    return Object.hash(
      latitude,
      longitude,
      timestamp,
      altitude,
      accuracy,
      isMocked,
    );
  }
}
