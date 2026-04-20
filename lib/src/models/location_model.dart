import 'dart:math';

/// Location data model
class LocationData {
  /// Latitude
  final double? latitude;

  /// Longitude
  final double? longitude;

  /// City name
  final String? city;

  /// Region/state
  final String? region;

  /// Country
  final String? country;

  /// Full address
  final String? address;

  /// Timestamp
  final DateTime? timestamp;

  LocationData({
    this.latitude,
    this.longitude,
    this.city,
    this.region,
    this.country,
    this.address,
    this.timestamp,
  });

  /// Create from JSON
  factory LocationData.fromJson(Map<String, dynamic> json) {
    return LocationData(
      latitude: json['latitude']?.toDouble(),
      longitude: json['longitude']?.toDouble(),
      city: json['city'],
      region: json['region'],
      country: json['country'],
      address: json['address'],
      timestamp: json['timestamp'] != null
          ? DateTime.parse(json['timestamp'])
          : null,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'latitude': latitude,
      'longitude': longitude,
      'city': city,
      'region': region,
      'country': country,
      'address': address,
      'timestamp': timestamp?.toIso8601String(),
    };
  }

  /// Check if location has coordinates
  bool get hasCoordinates => latitude != null && longitude != null;

  /// Get formatted location string
  String get formattedString {
    if (city != null) {
      if (region != null && country != null) {
        return '$city, $region, $country';
      }
      return city!;
    }
    if (hasCoordinates) {
      return '($latitude, $longitude)';
    }
    return 'Unknown location';
  }

  @override
  String toString() {
    return 'LocationData(lat: $latitude, lon: $longitude, city: $city)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is LocationData &&
        other.latitude == latitude &&
        other.longitude == longitude &&
        other.city == city &&
        other.country == country;
  }

  @override
  int get hashCode => Object.hash(latitude, longitude, city, country);
}

/// Latitude and longitude pair
class LatLong {
  final double latitude;
  final double longitude;

  LatLong({
    required this.latitude,
    required this.longitude,
  });

  /// Calculate distance between two points in kilometers
  double distanceTo(LatLong other) {
    const double earthRadiusKm = 6371.0;

    final double dLat = _degreesToRadians(other.latitude - latitude);
    final double dLon = _degreesToRadians(other.longitude - longitude);

    final double a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_degreesToRadians(latitude)) *
        cos(_degreesToRadians(other.latitude)) *
        sin(dLon / 2) *
        sin(dLon / 2);

    final double c = 2 * asin(sqrt(a));

    return earthRadiusKm * c;
  }

  double _degreesToRadians(double degrees) {
    return degrees * (pi / 180.0);
  }

  @override
  String toString() => 'LatLong(lat: $latitude, lon: $longitude)';
}
