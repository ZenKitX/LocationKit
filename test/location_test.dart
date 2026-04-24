import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/services.dart';
import 'package:location_kit/location_kit.dart';

void main() {
  group('LocationKit with Platform Channel', () {
    TestWidgetsFlutterBinding.ensureInitialized();

    setUp(() {
      // Setup mock platform channel
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
        const MethodChannel('location_kit'),
        (MethodCall methodCall) async {
          if (methodCall.method == 'getCurrentLocation') {
            return {
              'latitude': 39.9042,
              'longitude': 116.4074,
              'accuracy': 10.0,
              'timestamp': '2024-04-23T10:00:00.000',
            };
          }
          return null;
        },
      );
    });

    tearDown(() {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
        const MethodChannel('location_kit'),
        null,
      );
    });

    test('getCurrentLocation should return location from platform channel',
        () async {
      final location = await LocationKit.getCurrentLocation();

      expect(location.latitude, 39.9042);
      expect(location.longitude, 116.4074);
      expect(location.accuracy, 10.0);
    });

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
  });

  group('LocationKit with Mock Data (Platform Channel Not Implemented)', () {
    setUp(() {
      // Clear platform channel handler to trigger mock data
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
        const MethodChannel('location_kit'),
        (MethodCall methodCall) async {
          throw PlatformException(code: 'NOT_IMPLEMENTED');
        },
      );
    });

    tearDown(() {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
        const MethodChannel('location_kit'),
        null,
      );
    });

    test(
        'getCurrentLocation should return mock data when channel not implemented',
        () async {
      final location = await LocationKit.getCurrentLocation();

      // Should return Beijing mock data
      expect(location.latitude, 39.9042);
      expect(location.longitude, 116.4074);
    });
  });

  group('Models', () {
    test('LatLong should store latitude and longitude', () {
      const latLong = LatLong(39.9042, 116.4074);
      expect(latLong.latitude, 39.9042);
      expect(latLong.longitude, 116.4074);
    });

    test('LocationData should convert to LatLong', () {
      final location = const LocationData(
        latitude: 39.9042,
        longitude: 116.4074,
        timestamp: null,
      );
      final latLong = location.toLatLong();
      expect(latLong.latitude, 39.9042);
      expect(latLong.longitude, 116.4074);
    });

    test('LocationException should store message', () {
      const exception = LocationException('Test error');
      expect(exception.message, 'Test error');
      expect(exception.toString(), 'LocationException: Test error');
    });
  });
}
