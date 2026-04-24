import 'package:flutter_test/flutter_test.dart';
import 'package:location_kit/location_kit.dart';

void main() {
  group('LocationKit', () {
    test('calculateDistance should calculate distance correctly', () {
      const start = LatLong(39.9042, 116.4074); // Beijing
      const end = LatLong(31.2304, 121.4737); // Shanghai
      final distance = LocationKit.calculateDistance(start, end);

      // Distance between Beijing and Shanghai is ~1,067 km
      expect(distance, greaterThan(1000000)); // > 1000km
      expect(distance, lessThan(1200000)); // < 1200km
    });

    test('calculateDistance should return 0 for same location', () {
      const location = LatLong(39.9042, 116.4074);
      final distance = LocationKit.calculateDistance(location, location);
      expect(distance, equals(0));
    });

    test('getCurrentLocation should throw exception when not implemented', () {
      expect(
        () => LocationKit.getCurrentLocation(),
        throwsA(isA<LocationException>()),
      );
    });
  });

  group('LatLong', () {
    test('should create LatLong with latitude and longitude', () {
      const latLong = LatLong(39.9042, 116.4074);
      expect(latLong.latitude, 39.9042);
      expect(latLong.longitude, 116.4074);
    });
  });

  group('LocationData', () {
    test('should create LocationData with required fields', () {
      final location = const LocationData(
        latitude: 39.9042,
        longitude: 116.4074,
        timestamp: null,
      );
      expect(location.latitude, 39.9042);
      expect(location.longitude, 116.4074);
    });

    test('should convert to LatLong', () {
      final location = const LocationData(
        latitude: 39.9042,
        longitude: 116.4074,
        timestamp: null,
      );
      final latLong = location.toLatLong();
      expect(latLong.latitude, 39.9042);
      expect(latLong.longitude, 116.4074);
    });
  });

  group('LocationException', () {
    test('should create exception with message', () {
      const exception = LocationException('Test error');
      expect(exception.message, 'Test error');
      expect(exception.toString(), 'LocationException: Test error');
    });
  });
}
