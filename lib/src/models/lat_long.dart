/// Represents a geographic coordinate with latitude and longitude.
class LatLong {
  const LatLong(this.latitude, this.longitude);

  /// Latitude in degrees (between -90 and 90).
  final double latitude;

  /// Longitude in degrees (between -180 and 180).
  final double longitude;

  /// Creates a LatLong from a LocationData object.
  factory LatLong.fromLocationData(LocationData location) {
    return LatLong(location.latitude, location.longitude);
  }

  @override
  String toString() => 'LatLong($latitude, $longitude)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is LatLong &&
        other.latitude == latitude &&
        other.longitude == longitude;
  }

  @override
  int get hashCode => latitude.hashCode ^ longitude.hashCode;
}
