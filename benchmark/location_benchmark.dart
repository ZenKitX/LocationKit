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
  for (int i = 0; i < 100; i++) {
    _testDistance();
  }
  print('Warm up complete.\n');

  // Run benchmarks
  benchmarkLatLongCreation();
  benchmarkDistanceCalculation();
  benchmarkLocationDataCreation();

  print('\n=== Benchmark Complete ===');
}

void benchmarkLatLongCreation() {
  print('--- LatLong Creation Benchmark ---');

  const iterations = 100000;

  // Benchmark valid coordinates
  final stopwatch = Stopwatch()..start();

  for (int i = 0; i < iterations; i++) {
    const LatLong(39.9042, 116.4074);
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
    const LatLong(100.0, 200.0);
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

  const beijing = LatLong(39.9042, 116.4074);
  const shanghai = LatLong(31.2304, 121.4737);
  const guangzhou = LatLong(23.1291, 113.2644);
  const shenzhen = LatLong(22.5431, 114.0579);

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
      LocationKit.calculateDistance(from, to);
    }

    stopwatch.stop();
    final avgTime = stopwatch.elapsedMicroseconds / iterations;
    final distance = LocationKit.calculateDistance(from, to);
    print(
      '  calculateDistance (distance: ${(distance / 1000).toStringAsFixed(0)} km): '
      '${avgTime.toStringAsFixed(2)} μs/op ($iterations ops)',
    );
  }
  print('');
}

void benchmarkLocationDataCreation() {
  print('--- LocationData Creation Benchmark ---');

  const iterations = 10000;

  // Benchmark minimal location data
  final stopwatch = Stopwatch()..start();

  for (int i = 0; i < iterations; i++) {
    LocationData(
      latitude: 39.9042,
      longitude: 116.4074,
      timestamp: DateTime.now(),
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
      latitude: 39.9042,
      longitude: 116.4074,
      accuracy: 10.5,
      timestamp: DateTime.now(),
    );
  }

  stopwatch.stop();
  final avgTime2 = stopwatch.elapsedMicroseconds / iterations;
  print(
    '  LocationData (full): ${avgTime2.toStringAsFixed(2)} μs/op ($iterations ops)',
  );
  print('');
}

// Helper function for testing
void _testDistance() {
  const p1 = LatLong(39.9042, 116.4074);
  const p2 = LatLong(31.2304, 121.4737);
  LocationKit.calculateDistance(p1, p2);
}
