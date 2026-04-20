// ignore_for_file: avoid_print

/// Benchmark tests for LocationKit.
///
/// Run with: dart run benchmark/location_benchmark.dart
library;

import 'package:location_kit/location_kit.dart';

void main() {
  print('=== LocationKit Performance Benchmark ===\n');

  // Warm up
  print('Warming up...');
  final warmupService = LocationService();
  for (int i = 0; i < 100; i++) {
    warmupService._testDistance();
  }
  print('Warm up complete.\n');

  // Run benchmarks
  benchmarkLatLongCreation();
  benchmarkDistanceCalculation();
  benchmarkLocationDataCreation();
  benchmarkResultCreation();
  benchmarkErrorCreation();

  print('\n=== Benchmark Complete ===');
}

void benchmarkLatLongCreation() {
  print('--- LatLong Creation Benchmark ---');

  const iterations = 100000;

  // Benchmark valid coordinates
  final stopwatch = Stopwatch()..start();

  for (int i = 0; i < iterations; i++) {
    const LatLong(latitude: 39.9042, longitude: 116.4074);
  }

  stopwatch.stop();
  final avgTime1 = stopwatch.elapsedMicroseconds / iterations;
  print(
    '  LatLong (valid): ${avgTime1.toStringAsFixed(2)} μs/op ($iterations ops)',
  );

  // Benchmark invalid coordinates
  stopwatch.reset();
  stopwatch.start();

  for (int i = 0; i < iterations; i++) {
    const LatLong(latitude: 100.0, longitude: 200.0);
  }

  stopwatch.stop();
  final avgTime2 = stopwatch.elapsedMicroseconds / iterations;
  print(
    '  LatLong (invalid): ${avgTime2.toStringAsFixed(2)} μs/op ($iterations ops)',
  );
  print('');
}

void benchmarkDistanceCalculation() {
  print('--- Distance Calculation Benchmark ---');

  const beijing = LatLong(latitude: 39.9042, longitude: 116.4074);
  const shanghai = LatLong(latitude: 31.2304, longitude: 121.4737);
  const guangzhou = LatLong(latitude: 23.1291, longitude: 113.2644);
  const shenzhen = LatLong(latitude: 22.5431, longitude: 114.0579);

  final pairs = [
    (beijing, shanghai),
    (beijing, guangzhou),
    (beijing, shenzhen),
    (shanghai, guangzhou),
    (shanghai, shenzhen),
    (guangzhou, shenzhen),
  ];

  for (final (from, to) in pairs) {
    final stopwatch = Stopwatch()..start();
    const iterations = 100000;

    for (int i = 0; i < iterations; i++) {
      from.distanceTo(to);
    }

    stopwatch.stop();
    final avgTime = stopwatch.elapsedMicroseconds / iterations;
    print(
      '  distanceTo (distance: ${from.distanceTo(to).toStringAsFixed(0)} km): '
      '${avgTime.toStringAsFixed(2)} μs/op ($iterations ops)',
    );
  }
  print('');
}

void benchmarkLocationDataCreation() {
  print('--- LocationData Creation Benchmark ---');

  const latLong = LatLong(latitude: 39.9042, longitude: 116.4074);
  const iterations = 10000;

  // Benchmark minimal location data
  final stopwatch = Stopwatch()..start();

  for (int i = 0; i < iterations; i++) {
    LocationData(
      city: 'Beijing',
      latitude: 39.9042,
      longitude: 116.4074,
      country: 'China',
    );
  }

  stopwatch.stop();
  final avgTime1 = stopwatch.elapsedMicroseconds / iterations;
  print(
    '  LocationData (minimal): ${avgTime1.toStringAsFixed(2)} μs/op ($iterations ops)',
  );

  // Benchmark full location data
  stopwatch.reset();
  stopwatch.start();

  for (int i = 0; i < iterations; i++) {
    LocationData(
      city: 'Beijing',
      latitude: 39.9042,
      longitude: 116.4074,
      country: 'China',
      region: 'Beijing',
      address: 'Dongcheng District, Beijing, China',
    );
  }

  stopwatch.stop();
  final avgTime2 = stopwatch.elapsedMicroseconds / iterations;
  print(
    '  LocationData (full): ${avgTime2.toStringAsFixed(2)} μs/op ($iterations ops)',
  );
  print('');
}

void benchmarkResultCreation() {
  print('--- Result Creation Benchmark ---');

  const latLong = LatLong(latitude: 39.9042, longitude: 116.4074);
  final location = LocationData(
    city: 'Beijing',
    latitude: 39.9042,
    longitude: 116.4074,
    country: 'China',
  );

  final stopwatch = Stopwatch()..start();
  const iterations = 100000;

  for (int i = 0; i < iterations; i++) {
    final result = LocationResult.success(location);
    result.fold((data) => data.name.length, (error) => 0);
  }

  stopwatch.stop();
  final avgTime1 = stopwatch.elapsedMicroseconds / iterations;
  print(
    '  LocationResult.success: ${avgTime1.toStringAsFixed(2)} μs/op ($iterations ops)',
  );

  stopwatch.reset();
  stopwatch.start();

  for (int i = 0; i < iterations; i++) {
    final error = LocationError.permissionDenied('Test error');
    final result = LocationResult<LocationData>.failure(error);
    result.fold((data) => 0, (error) => error.message.length);
  }

  stopwatch.stop();
  final avgTime2 = stopwatch.elapsedMicroseconds / iterations;
  print(
    '  LocationResult.failure: ${avgTime2.toStringAsFixed(2)} μs/op ($iterations ops)',
  );
  print('');
}

void benchmarkErrorCreation() {
  print('--- Error Creation Benchmark ---');

  const iterations = 100000;

  // Benchmark permission denied error
  final stopwatch = Stopwatch()..start();

  for (int i = 0; i < iterations; i++) {
    LocationError.permissionDenied('Test error');
  }

  stopwatch.stop();
  final avgTime1 = stopwatch.elapsedMicroseconds / iterations;
  print(
    '  LocationError.permissionDenied: ${avgTime1.toStringAsFixed(2)} μs/op ($iterations ops)',
  );

  // Benchmark service disabled error
  stopwatch.reset();
  stopwatch.start();

  for (int i = 0; i < iterations; i++) {
    LocationError.serviceDisabled('Test error');
  }

  stopwatch.stop();
  final avgTime2 = stopwatch.elapsedMicroseconds / iterations;
  print(
    '  LocationError.serviceDisabled: ${avgTime2.toStringAsFixed(2)} μs/op ($iterations ops)',
  );

  // Benchmark timeout error
  stopwatch.reset();
  stopwatch.start();

  for (int i = 0; i < iterations; i++) {
    LocationError.timeout('Test error');
  }

  stopwatch.stop();
  final avgTime3 = stopwatch.elapsedMicroseconds / iterations;
  print(
    '  LocationError.timeout: ${avgTime3.toStringAsFixed(2)} μs/op ($iterations ops)',
  );

  // Benchmark unknown error
  stopwatch.reset();
  stopwatch.start();

  for (int i = 0; i < iterations; i++) {
    LocationError.unknown('Test error');
  }

  stopwatch.stop();
  final avgTime4 = stopwatch.elapsedMicroseconds / iterations;
  print(
    '  LocationError.unknown: ${avgTime4.toStringAsFixed(2)} μs/op ($iterations ops)',
  );
  print('');
}

// Extension method for testing
extension LocationServiceBenchmark on LocationService {
  void _testDistance() {
    const p1 = LatLong(latitude: 39.9042, longitude: 116.4074);
    const p2 = LatLong(latitude: 31.2304, longitude: 121.4737);
    calculateDistance(p1.latitude, p1.longitude, p2.latitude, p2.longitude);
  }
}
