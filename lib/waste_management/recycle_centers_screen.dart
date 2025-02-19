import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:math';
import 'package:ecopulse_local/waste_management/waste_service.dart';
import 'package:ecopulse_local/models/recyclingcenter.dart';

class RecyclingCentersScreen extends StatefulWidget {
  const RecyclingCentersScreen({Key? key}) : super(key: key);

  @override
  _RecyclingCentersScreenState createState() => _RecyclingCentersScreenState();
}

class _RecyclingCentersScreenState extends State<RecyclingCentersScreen> {
  final WasteService _wasteService = WasteService();
  bool _isLoading = true;
  List<RecyclingCenter> _centers = [];
  String? _errorMessage;
  Position? _userLocation;
  GoogleMapController? _mapController;
  Set<Marker> _markers = {};
  
  // Keep track of selected center for the bottom sheet
  RecyclingCenter? _selectedCenter;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
  try {
    setState(() => _isLoading = true); // Show loading spinner

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw 'Location permissions are denied';
      }
    }

    final position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    print("User Location: ${position.latitude}, ${position.longitude}");

    setState(() {
      _userLocation = position;
      _isLoading = false;
    });

    if (_mapController != null) {
      _mapController!.animateCamera(
        CameraUpdate.newLatLng(
          LatLng(position.latitude, position.longitude),
        ),
      );
    }
  } catch (e) {
    print("Location Error: $e");
    setState(() {
      _errorMessage = 'Failed to get location: $e';
      _isLoading = false;
    });
  }
}




  Future<void> _loadRecyclingCenters() async {
    try {
      final centers = await _wasteService.getRecyclingCenters(
        context,
        latitude: _userLocation?.latitude,
        longitude: _userLocation?.longitude,
      );
      
      // Create markers for each center
      final markers = centers.map((center) => Marker(
        markerId: MarkerId(center.id),
        position: LatLng(
          center.location!.latitude,
          center.location!.longitude,
        ),
        infoWindow: InfoWindow(
          title: center.name,
          snippet: center.address,
        ),
        onTap: () {
          setState(() => _selectedCenter = center);
          _showCenterDetails(center);
        },
      )).toSet();

      // Add user location marker
      if (_userLocation != null) {
        markers.add(Marker(
          markerId: const MarkerId('user_location'),
          position: LatLng(_userLocation!.latitude, _userLocation!.longitude),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
          infoWindow: const InfoWindow(title: 'Your Location'),
        ));
      }

      setState(() {
        _centers = centers;
        _markers = markers;
        _isLoading = false;
      });

      // Move camera to show all markers
      if (_mapController != null && _userLocation != null) {
        _fitMarkersAndUserLocation();
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load recycling centers: $e';
        _isLoading = false;
      });
    }
  }

  void _fitMarkersAndUserLocation() {
    if (_centers.isEmpty || _userLocation == null) return;

    // Create bounds that include all markers and user location
    LatLngBounds bounds = LatLngBounds(
  southwest: LatLng(_userLocation!.latitude, _userLocation!.longitude),
  northeast: LatLng(_userLocation!.latitude, _userLocation!.longitude),
);

for (var center in _centers) {
  final LatLng centerLatLng = LatLng(center.location!.latitude, center.location!.longitude);
  bounds = LatLngBounds(
    southwest: LatLng(
      min(bounds.southwest.latitude, centerLatLng.latitude),
      min(bounds.southwest.longitude, centerLatLng.longitude),
    ),
    northeast: LatLng(
      max(bounds.northeast.latitude, centerLatLng.latitude),
      max(bounds.northeast.longitude, centerLatLng.longitude),
    ),
  );
}

    // Add padding to bounds
    _mapController?.animateCamera(
      CameraUpdate.newLatLngBounds(bounds, 50.0),
    );
  }

  void _showCenterDetails(RecyclingCenter center) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.4,
        minChildSize: 0.2,
        maxChildSize: 0.8,
        builder: (_, controller) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          padding: const EdgeInsets.all(16),
          child: ListView(
            controller: controller,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Text(
                center.name,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              _buildInfoRow(Icons.location_on, center.address),
              if (center.phone != null)
                _buildInfoRow(Icons.phone, center.phone!),
              if (center.operatingHours != null)
                _buildInfoRow(Icons.access_time, center.operatingHours!),
              const SizedBox(height: 16),
              const Text(
                'Accepted Materials',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: center.acceptedMaterials.map((material) => Chip(
                  label: Text(material),
                  backgroundColor: Colors.green.withOpacity(0.1),
                )).toList(),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                icon: const Icon(Icons.directions),
                label: const Text('Get Directions'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding: const EdgeInsets.all(16),
                ),
                onPressed: () => _openInGoogleMaps(center),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _openInGoogleMaps(RecyclingCenter center) async {
    final url = 'https://www.google.com/maps/dir/?api=1'
        '&destination=${center.location!.latitude},${center.location!.longitude}'
        '&travelmode=driving';
    
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open Google Maps')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Recycling Centers'),
          backgroundColor: Colors.green,
          bottom: const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.map), text: 'Map'),
              Tab(icon: Icon(Icons.list), text: 'List'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // Map View
            _buildMapView(),
            // List View
            _buildListView(),
          ],
        ),
      ),
    );
  }

  Widget _buildMapView() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return Center(child: Text(_errorMessage!));
    }

    return GoogleMap(
  initialCameraPosition: CameraPosition(
    target: _userLocation != null
        ? LatLng(_userLocation!.latitude, _userLocation!.longitude)
        : LatLng(10.8505, 76.2711), // Default to Kerala
    zoom: 12,
  ),
  myLocationEnabled: true, // Show user's location
  myLocationButtonEnabled: true, // Enable location button
  zoomControlsEnabled: true, // Enable zoom controls
  zoomGesturesEnabled: true, // Allow pinch zoom
  scrollGesturesEnabled: true, // Allow panning/moving
  rotateGesturesEnabled: true, // Allow rotation
  tiltGesturesEnabled: true, // Allow tilting
  mapToolbarEnabled: true, // Enable toolbar for navigation
  onMapCreated: (controller) {
    _mapController = controller;
      _mapController!.setMapStyle(null); // Reset style (if needed)
    if (_userLocation != null) {
      _mapController?.animateCamera(
        CameraUpdate.newLatLng(
          LatLng(_userLocation!.latitude, _userLocation!.longitude),
        ),
      );
    }
    else {
    // Move to default location if GPS is unavailable
    _mapController!.animateCamera(
      CameraUpdate.newLatLng(LatLng(10.8505, 76.2711)), // Kerala
    );
  }
  },
);
}


  // Replace the _buildListView() method in the RecyclingCentersScreen with this updated version:

Widget _buildListView() {
  if (_isLoading) {
    return const Center(child: CircularProgressIndicator());
  }

  if (_errorMessage != null) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            _errorMessage!,
            style: const TextStyle(color: Colors.red),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _getCurrentLocation,
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  return Stack(
    children: [
      ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _centers.length,
        itemBuilder: (context, index) {
          final center = _centers[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 16),
            child: ListTile(
              title: Text(center.name),
              subtitle: Text(center.address),
              trailing: IconButton(
                icon: const Icon(Icons.info_outline),
                onPressed: () => _showCenterDetails(center),
              ),
            ),
          );
        },
      ),
      Positioned(
        bottom: 16,
        right: 16,
        child: FloatingActionButton(
          onPressed: () async {
            final result = await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const AddRecyclingCenterScreen(),
              ),
            );
            
            // Refresh the list if a new center was added
            if (result == true) {
              _loadRecyclingCenters();
            }
          },
          backgroundColor: Colors.green,
          child: const Icon(Icons.add),
        ),
      ),
    ],
  );
}