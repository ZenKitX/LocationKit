import 'package:flutter_test/flutter_test.dart';
import 'package:location_kit/location_kit.dart';

void main() {
  group('LocationError', () {
    test('should create permission denied error', () {
      final error = LocationError.permissionDenied('Permission denied');
      expect(error.type, LocationErrorType.permissionDenied);
      expect(error.message, 'Permission denied');
    });

    test('should create service disabled error', () {
      final error = LocationError.serviceDisabled('Service disabled');
      expect(error.type, LocationErrorType.serviceDisabled);
      expect(error.message, 'Service disabled');
    });

    test('should create timeout error', () {
      final error = LocationError.timeout('Timeout');
      expect(error.type, LocationErrorType.timeout);
      expect(error.message, 'Timeout');
    });

    test('should create unknown error', () {
      final error = LocationError.unknown('Unknown error');
      expect(error.type, LocationErrorType.unknown);
      expect(error.message, 'Unknown error');
    });
  });

  group('Result', () {
    test('should create success result', () {
      final result = Result.success(42);
      expect(result.isSuccess, isTrue);
      expect(result.isFailure, isFalse);
      expect(result.data, equals(42));
    });

    test('should create failure result', () {
      final error = LocationError.permissionDenied('Denied');
      final result = Result<int>.failure(error);
      expect(result.isSuccess, isFalse);
      expect(result.isFailure, isTrue);
      expect(result.error, equals(error));
    });

    test('fold should execute success callback', () {
      final result = Result.success(10);
      final value = result.fold(
        (data) => data * 2,
        (error) => 0,
      );
      expect(value, equals(20));
    });

    test('fold should execute failure callback', () {
      final error = LocationError.permissionDenied('Failed');
      final result = Result<int>.failure(error);
      final value = result.fold(
        (data) => data * 2,
        (error) => error.message.length,
      );
      expect(value, equals(6));
    });

    test('map should transform success data', () {
      final result = Result.success(10).map((data) => data.toString());
      expect(result.isSuccess, isTrue);
      expect(result.data, equals('10'));
    });

    test('map should preserve failure', () {
      final error = LocationError.permissionDenied('Failed');
      final result = Result<int>.failure(error).map((data) => data.toString());
      expect(result.isSuccess, isFalse);
      expect(result.error, equals(error));
    });
  });

  group('LatLong', () {
    test('should create LatLong', () {
      const latLong = LatLong(39.9042, 116.4074);
      expect(latLong.latitude, 39.9042);
      expect(latLong.longitude, 116.4074);
    });

    test('should create LatLong from LocationData', () {
      const location = LocationData(
        latitude: 39.9042,
        longitude: 116.4074,
        timestamp: null,
      );
      final latLong = LatLong.fromLocationData(location);
      expect(latLong.latitude, 39.9042);
      expect(latLong.longitude, 116.4074);
    });
  });

  group('LocationData', () {
    test('should create location data', () {
      const location = LocationData(
        latitude: 39.9042,
        longitude: 116.4074,
        timestamp: null,
        altitude: 50.0,
        accuracy: 10.0,
      );
      expect(location.latitude, 39.9042);
      expect(location.longitude, 116.4074);
      expect(location.altitude, 50.0);
      expect(location.accuracy, 10.0);
    });

    test('should convert to LatLong', () {
      const location = LocationData(
        latitude: 39.9042,
        longitude: 116.4074,
        timestamp: null,
      );
      final latLong = location.toLatLong();
      expect(latLong.latitude, 39.9042);
      expect(latLong.longitude, 116.4074);
    });

    test('should compare equality', () {
      const location1 = LocationData(
        latitude: 39.9042,
        longitude: 116.4074,
        timestamp: null,
      );
      const location2 = LocationData(
        latitude: 39.9042,
        longitude: 116.4074,
        timestamp: null,
      );
      expect(location1, equals(location2));
    });
  });

  group('LocationPermission', () {
    test('should check isGranted', () {
      expect(LocationPermission.whileInUse.isGranted, isTrue);
      expect(LocationPermission.always.isGranted, isTrue);
      expect(LocationPermission.denied.isGranted, isFalse);
    });

    test('should check isDenied', () {
      expect(LocationPermission.denied.isDenied, isTrue);
      expect(LocationPermission.deniedForever.isDenied, isTrue);
      expect(LocationPermission.whileInUse.isDenied, isFalse);
    });

    test('should check isPermanentlyDenied', () {
      expect(LocationPermission.deniedForever.isPermanentlyDenied, isTrue);
      expect(LocationPermission.denied.isPermanentlyDenied, isFalse);
    });
  });

  group('LocationKit - Static Methods', () {
    test('calculateDistance should return distance in meters', () {
      const start = LatLong(39.9042, 116.4074); // Beijing
      const end = LatLong(31.2304, 121.4737); // Shanghai
      final distance = LocationKit.calculateDistance(start, end);
      expect(distance, greaterThan(1000000)); // > 1000km
      expect(distance, lessThan(1500000)); // < 1500km
    });

    test('calculateBearing should return bearing in degrees', () {
      const start = LatLong(39.9042, 116.4074); // Beijing
      const end = LatLong(31.2304, 121.4737); // Shanghai
      final bearing = LocationKit.calculateBearing(start, end);
      expect(bearing, greaterThan(0));
      expect(bearing, lessThan(360));
    });
  });
}
