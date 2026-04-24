/// Represents a geographic coordinate with latitude and longitude.
class LatLong {
  const LatLong(this.latitude, this.longitude);

  /// Latitude in degrees (between -90 and 90).
  final double latitude;

  /// Longitude in degrees (between -180 and 180).
  final double longitude;

  @override
  String toString() => 'LatLong($latitude, $longitude)';
}
