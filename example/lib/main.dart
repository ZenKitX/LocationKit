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
  final LocationService _locationService = LocationService();
  LocationResult<LocationData>? _currentLocation;
  LocationResult<String>? _reverseGeocodeResult;
  double? _distance;
  bool _isLoading = false;

  final LatLong _beijing = const LatLong(latitude: 39.9042, longitude: 116.4074);
  final LatLong _shanghai = const LatLong(latitude: 31.2304, longitude: 121.4737);

  Future<void> _getCurrentLocation() async {
    setState(() {
      _isLoading = true;
      _currentLocation = null;
    });

    final result = await _locationService.getCurrentLocation();

    setState(() {
      _currentLocation = result;
      _isLoading = false;
    });
  }

  Future<void> _reverseGeocode(LatLong coordinates) async {
    setState(() {
      _isLoading = true;
      _reverseGeocodeResult = null;
    });

    final result = await _locationService.reverseGeocode(coordinates.latitude, coordinates.longitude);

    setState(() {
      _reverseGeocodeResult = result;
      _isLoading = false;
    });
  }

  Future<void> _calculateDistance() async {
    final distance = _locationService.calculateDistance(
      _beijing.latitude,
      _beijing.longitude,
      _shanghai.latitude,
      _shanghai.longitude,
    );
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
            _buildSectionCard(
              title: 'Current Location',
              icon: Icons.my_location,
              child: Column(
                children: [
                  ElevatedButton.icon(
                    onPressed: _isLoading ? null : _getCurrentLocation,
                    icon: _isLoading
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.location_searching),
                    label: const Text('Get Current Location'),
                  ),
                  const SizedBox(height: 16),
                  if (_currentLocation != null) _buildLocationResult(_currentLocation!),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _buildSectionCard(
              title: 'Reverse Geocode',
              icon: Icons.map,
              child: Column(
                children: [
                  _buildCoordinatesInput(_beijing, 'Beijing'),
                  const SizedBox(height: 8),
                  _buildCoordinatesInput(_shanghai, 'Shanghai'),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: _isLoading ? null : () => _reverseGeocode(_beijing),
                    icon: const Icon(Icons.search),
                    label: const Text('Reverse Geocode Beijing'),
                  ),
                  const SizedBox(height: 16),
                  if (_reverseGeocodeResult != null) _buildReverseGeocodeResult(_reverseGeocodeResult!),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _buildSectionCard(
              title: 'Distance Calculation',
              icon: Icons.straighten,
              child: Column(
                children: [
                  _buildCoordinatesInput(_beijing, 'Beijing'),
                  const SizedBox(height: 8),
                  _buildCoordinatesInput(_shanghai, 'Shanghai'),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: _isLoading ? null : _calculateDistance,
                    icon: const Icon(Icons.calculate),
                    label: const Text('Calculate Distance'),
                  ),
                  const SizedBox(height: 16),
                  if (_distance != null)
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.route, size: 32),
                            const SizedBox(width: 16),
                            Text(
                              '${_distance!.toStringAsFixed(2)} km',
                              style: Theme.of(context).textTheme.headlineSmall,
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _buildSectionCard(
              title: 'Permission Management',
              icon: Icons.security,
              child: Column(
                children: [
                  _buildPermissionStatus(),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () async {
                      final context = this.context;
                      final result = await _locationService.hasPermission();
                      if (!mounted) return;
                      final hasPermission = result.isSuccess && result.data == true;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            hasPermission ? 'Permission Granted' : 'Permission Denied',
                          ),
                        ),
                      );
                    },
                    icon: const Icon(Icons.check_circle),
                    label: const Text('Check Permission'),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton.icon(
                    onPressed: () async {
                      final context = this.context;
                      final result = await _locationService.requestPermission();
                      if (!mounted) return;
                      final granted = result.isSuccess && result.data == true;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            granted ? 'Permission Granted' : 'Permission Denied',
                          ),
                        ),
                      );
                    },
                    icon: const Icon(Icons.settings),
                    label: const Text('Request Permission'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionCard({required String title, required IconData icon, required Widget child}) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 24),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ],
            ),
            const SizedBox(height: 16),
            child,
          ],
        ),
      ),
    );
  }

  Widget _buildCoordinatesInput(LatLong coordinates, String label) {
    return Card(
      color: Colors.grey[50],
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Lat: ${coordinates.latitude.toStringAsFixed(4)}, '
              'Lon: ${coordinates.longitude.toStringAsFixed(4)}',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontFamily: 'monospace',
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReverseGeocodeResult(LocationResult<String> result) {
    return result.fold(
      (address) => Card(
        color: Colors.green.shade50,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.check_circle, color: Colors.green),
                  const SizedBox(width: 8),
                  Text(
                    'Address Found',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Colors.green.shade700,
                        ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _buildDetailRow('Address', address),
            ],
          ),
        ),
      ),
      (error) => Card(
        color: Colors.red.shade50,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              const Icon(Icons.error, color: Colors.red),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Error: ${_getErrorTypeName(error.type)}',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: Colors.red.shade700,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      error.message,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLocationResult(LocationResult<LocationData> result) {
    return result.fold(
      (location) => Card(
        color: Colors.green.shade50,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.check_circle, color: Colors.green),
                  const SizedBox(width: 8),
                  Text(
                    'Location Found',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Colors.green.shade700,
                        ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _buildDetailRow('Name', location.name ?? 'Unknown'),
              if (location.city != null) _buildDetailRow('City', location.city!),
              if (location.region != null) _buildDetailRow('Region', location.region!),
              _buildDetailRow('Country', location.country ?? 'Unknown'),
              if (location.address != null) _buildDetailRow('Address', location.address!),
              const SizedBox(height: 8),
              if (location.coordinates != null)
                _buildDetailRow(
                  'Coordinates',
                  '${location.coordinates!.latitude.toStringAsFixed(4)}, ${location.coordinates!.longitude.toStringAsFixed(4)}',
                ),
            ],
          ),
        ),
      ),
      (error) => Card(
        color: Colors.red.shade50,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              const Icon(Icons.error, color: Colors.red),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Error: ${_getErrorTypeName(error.type)}',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: Colors.red.shade700,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      error.message,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPermissionStatus() {
    return Card(
      color: Colors.blue.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            const Icon(Icons.info, color: Colors.blue),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Note: This is a mock implementation. '
                'In production, you would integrate with actual GPS services '
                'like the "location" or "geolocator" package.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.blue.shade700,
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getErrorTypeName(LocationErrorType type) {
    switch (type) {
      case LocationErrorType.permissionDenied:
        return 'Permission Denied';
      case LocationErrorType.permissionPermanentlyDenied:
        return 'Permission Permanently Denied';
      case LocationErrorType.serviceDisabled:
        return 'Service Disabled';
      case LocationErrorType.timeout:
        return 'Timeout';
      case LocationErrorType.unknown:
        return 'Unknown Error';
    }
  }
}
