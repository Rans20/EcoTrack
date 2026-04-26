import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  LocationData? _currentLocation;
  final Location _location = Location();

  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _initLocation();
  }

  Future<void> _initLocation() async {
    try {
      bool serviceEnabled;
      PermissionStatus permissionGranted;

      serviceEnabled = await _location.serviceEnabled();
      if (!serviceEnabled) {
        serviceEnabled = await _location.requestService();
        if (!serviceEnabled) {
          setState(() {
            _isLoading = false;
            _errorMessage = 'Location services are disabled.';
          });
          return;
        }
      }

      permissionGranted = await _location.hasPermission();
      if (permissionGranted == PermissionStatus.denied) {
        permissionGranted = await _location.requestPermission();
        if (permissionGranted != PermissionStatus.granted) {
          setState(() {
            _isLoading = false;
            _errorMessage = 'Location permissions are denied.';
          });
          return;
        }
      }

      _currentLocation = await _location.getLocation().timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw 'Location request timed out.';
        },
      );
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary;
    final secondaryColor = theme.colorScheme.secondary;

    return Scaffold(
      body: Stack(
        children: [
          if (_currentLocation != null)
            GoogleMap(
              initialCameraPosition: CameraPosition(
                target: LatLng(_currentLocation!.latitude!, _currentLocation!.longitude!),
                zoom: 15,
              ),
              onMapCreated: (controller) {
                // Use controller if needed later
              },
              myLocationEnabled: true,
              myLocationButtonEnabled: false,
              zoomControlsEnabled: false,
            )
          else if (_isLoading)
            Center(child: CircularProgressIndicator(color: primaryColor))
          else
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.location_off_outlined, size: 64, color: Color(0xFFB2BEC3)),
                  const SizedBox(height: 16),
                  Text(_errorMessage ?? 'Could not retrieve location.', style: const TextStyle(color: Color(0xFF636E72), fontWeight: FontWeight.w500)),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _isLoading = true;
                        _errorMessage = null;
                      });
                      _initLocation();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          
          // Top Overlay
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Icon(Icons.navigation_outlined, color: secondaryColor),
                    const SizedBox(width: 12),
                    const Text('Searching for low-emission paths...', style: TextStyle(color: Color(0xFF95A5A6), fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
            ),
          ),

          // Bottom Panel
          Positioned(
            bottom: 30,
            left: 20,
            right: 20,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildTypeSelector(theme),
                const SizedBox(height: 16),
                _buildSuggestionBox(theme),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypeSelector(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: ['Driving', 'Hiking', 'Walking'].map((type) {
          final isSelected = type == 'Hiking';
          return Expanded(
            child: GestureDetector(
              onTap: () {},
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: isSelected ? theme.colorScheme.primary : Colors.transparent,
                  borderRadius: BorderRadius.circular(18),
                ),
                alignment: Alignment.center,
                child: Text(
                  type,
                  style: TextStyle(
                    color: isSelected ? Colors.white : theme.colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildSuggestionBox(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 25,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.eco_outlined, color: theme.colorScheme.secondary, size: 20),
              const SizedBox(width: 10),
              Text(
                'OPTIMAL ROUTE FOUND',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                  color: theme.colorScheme.secondary,
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Shorter route via Oak Avenue',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: theme.colorScheme.primary, letterSpacing: -0.5),
          ),
          Text(
            '2.4 km shorter, 8 min faster',
            style: TextStyle(fontSize: 15, color: theme.colorScheme.secondary, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 18),
              ),
              child: const Text('Start Journey', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
            ),
          ),
        ],
      ),
    );
  }
}
