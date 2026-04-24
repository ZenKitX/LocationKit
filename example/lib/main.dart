import 'package:flutter/material.dart';
import 'package:location_kit/location_kit.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'LocationKit Example',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const LocationExamplePage(),
    );
  }
}

class LocationExamplePage extends StatefulWidget {
  const LocationExamplePage({super.key});

  @override
  State<LocationExamplePage> createState() => _LocationExamplePageState();
}

class _LocationExamplePageState extends State<LocationExamplePage> {
  LocationData? _currentLocation;
  String? _errorMessage;
  double? _distance;
  bool _isLoading = false;

  final LatLong _beijing = const LatLong(39.9042, 116.4074);
  final LatLong _shanghai = const LatLong(31.2304, 121.4737);

  Future<void> _getCurrentLocation() async {
    setState(() {
      _isLoading = true;
      _currentLocation = null;
      _errorMessage = null;
    });

    try {
      final location = await LocationKit.getCurrentLocation();
      setState(() {
        _currentLocation = location;
        _isLoading = false;
      });
    } on LocationException catch (e) {
      setState(() {
        _errorMessage = e.message;
        _isLoading = false;
      });
    }
  }

  void _calculateDistance() {
    final distance = LocationKit.calculateDistance(_beijing, _shanghai);
    setState(() {
      _distance = distance;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('LocationKit Example'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildGetLocationSection(),
            const SizedBox(height: 24),
            _buildDistanceSection(),
            const SizedBox(height: 24),
            _buildCoordinatesSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildGetLocationSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Get Current Location',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            if (_isLoading)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: CircularProgressIndicator(),
                ),
              )
            else if (_errorMessage != null)
              _buildErrorCard(_errorMessage!)
            else if (_currentLocation != null)
              _buildLocationCard(_currentLocation!)
            else
              const Text(
                'Click the button to get current location',
                style: TextStyle(color: Colors.grey),
              ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _isLoading ? null : _getCurrentLocation,
              child: const Text('Get Location'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDistanceSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Calculate Distance',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text('Beijing: ${_beijing.latitude}, ${_beijing.longitude}'),
            Text('Shanghai: ${_shanghai.latitude}, ${_shanghai.longitude}'),
            if (_distance != null) ...[
              const SizedBox(height: 8),
              Text(
                'Distance: ${(_distance! / 1000).toStringAsFixed(2)} km',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
            ],
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _distance == null ? _calculateDistance : null,
              child: const Text('Calculate Distance'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCoordinatesSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Test Coordinates',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            _buildCoordinateRow('Beijing', _beijing),
            _buildCoordinateRow('Shanghai', _shanghai),
            _buildCoordinateRow('Guangzhou', const LatLong(23.1291, 113.2644)),
            _buildCoordinateRow('Shenzhen', const LatLong(22.5431, 114.0579)),
          ],
        ),
      ),
    );
  }

  Widget _buildCoordinateRow(String name, LatLong coord) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          SizedBox(
            width: 100,
            child: Text(
              name,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(
            child: Text(
              '${coord.latitude.toStringAsFixed(4)}, ${coord.longitude.toStringAsFixed(4)}',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationCard(LocationData location) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.location_on, color: Colors.blue),
              SizedBox(width: 8),
              Text(
                'Location Found',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 8),
          _buildInfoRow('Latitude', '${location.latitude.toStringAsFixed(6)}°'),
          _buildInfoRow(
            'Longitude',
            '${location.longitude.toStringAsFixed(6)}°',
          ),
          _buildInfoRow('Accuracy', '${location.accuracy.toStringAsFixed(1)}m'),
          _buildInfoRow('Timestamp', '${location.timestamp.toLocal()}'),
        ],
      ),
    );
  }

  Widget _buildErrorCard(String message) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.red.shade200),
      ),
      child: Row(
        children: [
          const Icon(Icons.error, color: Colors.red),
          const SizedBox(width: 8),
          Expanded(
            child: Text(message, style: const TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.black54,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}
