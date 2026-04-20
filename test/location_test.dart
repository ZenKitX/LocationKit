import 'package:flutter_test/flutter_test.dart';
import 'package:location_kit/location_kit.dart';

void main() {
  group('LatLong', () {
    test('should create latitude and longitude', () {
      const latLong = LatLong(latitude: 39.9042, longitude: 116.4074);
      expect(latLong.latitude, 39.9042);
      expect(latLong.longitude, 116.4074);
    });

    test('should validate valid latitude', () {
      const latLong = LatLong(latitude: 0.0, longitude: 0.0);
      expect(latLong.isValid, isTrue);
    });

    test('should validate invalid latitude', () {
      const latLong1 = LatLong(latitude: 91.0, longitude: 0.0);
      const latLong2 = LatLong(latitude: -91.0, longitude: 0.0);
      expect(latLong1.isValid, isFalse);
      expect(latLong2.isValid, isFalse);
    });

    test('should validate valid longitude', () {
      const latLong = LatLong(latitude: 0.0, longitude: 180.0);
      expect(latLong.isValid, isTrue);
    });

    test('should validate invalid longitude', () {
      const latLong1 = LatLong(latitude: 0.0, longitude: 181.0);
      const latLong2 = LatLong(latitude: 0.0, longitude: -181.0);
      expect(latLong1.isValid, isFalse);
      expect(latLong2.isValid, isFalse);
    });

    test('should calculate distance between two points', () {
      const beijing = LatLong(latitude: 39.9042, longitude: 116.4074);
      const shanghai = LatLong(latitude: 31.2304, longitude: 121.4737);
      final distance = beijing.distanceTo(shanghai);
      expect(distance, greaterThan(1000)); // ~1068 km
      expect(distance, lessThan(1200));
    });

    test('should calculate zero distance for same point', () {
      const point = LatLong(latitude: 39.9042, longitude: 116.4074);
      final distance = point.distanceTo(point);
      expect(distance, closeTo(0, 0.001));
    });
  });

  group('LocationData', () {
    test('should create location data', () {
      const latLong = LatLong(latitude: 39.9042, longitude: 116.4074);
      final location = LocationData(
        name: 'Beijing',
        coordinates: latLong,
        country: 'China',
      );
      expect(location.name, 'Beijing');
      expect(location.coordinates, latLong);
      expect(location.country, 'China');
    });

    test('should create location data with optional fields', () {
      const latLong = LatLong(latitude: 39.9042, longitude: 116.4074);
      final location = LocationData(
        name: 'Beijing',
        coordinates: latLong,
        country: 'China',
        region: 'Beijing',
        city: 'Beijing',
        address: 'Dongcheng District',
      );
      expect(location.region, 'Beijing');
      expect(location.city, 'Beijing');
      expect(location.address, 'Dongcheng District');
    });
  });

  group('LocationErrorType', () {
    test('should have correct error types', () {
      expect(LocationErrorType.permissionDenied.index, equals(0));
      expect(LocationErrorType.serviceDisabled.index, equals(1));
      expect(LocationErrorType.timeout.index, equals(2));
      expect(LocationErrorType.unknown.index, equals(3));
    });
  });

  group('LocationError', () {
    test('should create permission denied error', () {
      final error = LocationError.permissionDenied('Permission denied');
      expect(error.type, LocationErrorType.permissionDenied);
      expect(error.message, 'Permission denied');
    });

    test('should create service disabled error', () {
      final error = LocationError.serviceDisabled('GPS disabled');
      expect(error.type, LocationErrorType.serviceDisabled);
      expect(error.message, 'GPS disabled');
    });

    test('should create timeout error', () {
      final error = LocationError.timeout('Request timeout');
      expect(error.type, LocationErrorType.timeout);
      expect(error.message, 'Request timeout');
    });

    test('should create unknown error', () {
      final error = LocationError.unknown('Unknown error');
      expect(error.type, LocationErrorType.unknown);
      expect(error.message, 'Unknown error');
    });
  });

  group('LocationResult', () {
    test('should create success result', () {
      const latLong = LatLong(latitude: 39.9042, longitude: 116.4074);
      final location = LocationData(
        name: 'Beijing',
        coordinates: latLong,
        country: 'China',
      );
      final result = LocationResult.success(location);
      expect(result.isSuccess, isTrue);
      expect(result.isFailure, isFalse);
      expect(result.data, equals(location));
    });

    test('should create failure result', () {
      final error = LocationError.permissionDenied('Denied');
      final result = LocationResult<LocationData>.failure(error);
      expect(result.isSuccess, isFalse);
      expect(result.isFailure, isTrue);
      expect(result.error, equals(error));
    });

    test('fold should execute success callback', () {
      const latLong = LatLong(latitude: 39.9042, longitude: 116.4074);
      final location = LocationData(
        name: 'Beijing',
        coordinates: latLong,
        country: 'China',
      );
      final result = LocationResult.success(location);
      final value = result.fold(
        (data) => data.name.length,
        (error) => 0,
      );
      expect(value, equals(7)); // "Beijing".length
    });

    test('fold should execute failure callback', () {
      final error = LocationError.permissionDenied('Denied');
      final result = LocationResult<LocationData>.failure(error);
      final value = result.fold(
        (data) => 0,
        (error) => error.message.length,
      );
      expect(value, equals(6)); // "Denied".length
    });
  });

  group('LocationService', () {
    late LocationService service;

    setUp(() {
      service = LocationService();
    });

    test('should return mock location for getCurrentLocation', () async {
      final result = await service.getCurrentLocation();
      expect(result, isNotNull);
      expect(result.isSuccess, isTrue);
      expect(result.data, isNotNull);
    });

    test('should return mock location for reverseGeocode', () async {
      const latLong = LatLong(latitude: 39.9042, longitude: 116.4074);
      final result = await service.reverseGeocode(latLong);
      expect(result, isNotNull);
      expect(result.isSuccess, isTrue);
      expect(result.data, isNotNull);
    });

    test('should return distance between two locations', () async {
      const beijing = LatLong(latitude: 39.9042, longitude: 116.4074);
      const shanghai = LatLong(latitude: 31.2304, longitude: 121.4737);
      final distance = await service.calculateDistance(beijing, shanghai);
      expect(distance, greaterThan(1000));
    });

    test('should check permission status', () async {
      final hasPermission = await service.hasPermission();
      expect(hasPermission, isA<bool>());
    });

    test('should request permission', () async {
      final granted = await service.requestPermission();
      expect(granted, isA<bool>());
    });
  });
}
