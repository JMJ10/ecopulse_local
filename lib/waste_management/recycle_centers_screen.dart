import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:ecopulse_local/models/recyclingcenter.dart';
import 'package:ecopulse_local/services/location_service.dart';
import 'package:ecopulse_local/waste_management/waste_service.dart';
import 'package:ecopulse_local/utils/map_helper.dart';
import 'package:url_launcher/url_launcher.dart';

class RecyclingCentersScreen extends StatefulWidget {
  const RecyclingCentersScreen({Key? key}) : super(key: key);

  @override
  _RecyclingCentersScreenState createState() => _RecyclingCentersScreenState();
}

class _RecyclingCentersScreenState extends State<RecyclingCentersScreen> {
  final Completer<GoogleMapController> _mapControllerCompleter = Completer();
  GoogleMapController? _mapController;
  final WasteService _wasteService = WasteService();
  
  List<RecyclingCenter> _centers = [];
  Set<Marker> _markers = {};
  Position? _userLocation;
  LatLng? _userLatLng;
  bool _isLoading = true;
  bool _error = false;
  String _errorMessage = '';
  bool _isMapReady = false;
  
  // Selected center to show details
  RecyclingCenter? _selectedCenter;
  
  @override
  void initState() {
    super.initState();
    _initializeMap();
  }
  
  Future<void> _initializeMap() async {
    setState(() {
      _isLoading = true;
      _error = false;
    });
    
    try {
      // 1. Get user location
      await _getCurrentLocation();
      
      // 2. Fetch recycling centers (passing user location for potential sorting by distance)
      await _loadRecyclingCenters();
      
      // 3. Update map markers
      _updateMapMarkers();
    } catch (e) {
      setState(() {
        _error = true;
        _errorMessage = e.toString();
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
  
  Future<void> _getCurrentLocation() async {
    try {
      Position? position = await LocationService.getCurrentLocation(context);
      
      if (position != null) {
        setState(() {
          _userLocation = position;
          _userLatLng = LatLng(position.latitude, position.longitude);
        });
      }
    } catch (e) {
      // Handle location errors
      print('Error getting location: $e');
      // We'll still show the map with recycling centers even if user location fails
    }
  }
  
  Future<void> _loadRecyclingCenters() async {
    try {
      // If we have user location, use it for location-based search
      if (_userLatLng != null) {
        _centers = await _wasteService.getRecyclingCenters(
          context,
          latitude: _userLatLng!.latitude,
          longitude: _userLatLng!.longitude,
        );
      } else {
        // Otherwise just get all centers
        _centers = await _wasteService.getRecyclingCenters(context);
      }
    } catch (e) {
      print('Error loading recycling centers: $e');
      rethrow;
    }
  }
  
  void _updateMapMarkers() {
    // Create markers for recycling centers
    Set<Marker> markers = MapHelper.generateCenterMarkers(
      _centers, 
      (center) {
        setState(() {
          _selectedCenter = center;
        });
      },
    );
    
    // Add user location marker if available
    if (_userLatLng != null) {
      markers.add(MapHelper.generateUserMarker(_userLatLng!));
    }
    
    setState(() {
      _markers = markers;
    });
  }
  
  Future<void> _moveToCurrentLocation() async {
    if (_userLatLng == null) {
      // Try to get current location again
      await _getCurrentLocation();
      
      if (_userLatLng == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Unable to get your current location')),
        );
        return;
      }
    }
    
    final GoogleMapController controller = await _mapControllerCompleter.future;
    controller.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: _userLatLng!,
          zoom: 15,
        ),
      ),
    );
  }
  
  Future<void> _fitAllMarkers() async {
    if (_centers.isEmpty) return;
    
    final GoogleMapController controller = await _mapControllerCompleter.future;
    
    // Calculate bounds to fit all markers and user location
    final bounds = MapHelper.calculateBounds(_centers, _userLatLng);
    
    // Animate camera to show all markers
    controller.animateCamera(
      CameraUpdate.newLatLngBounds(bounds, 50), // 50 is padding
    );
  }
  
  void _centerMapOnLocation(LatLng location) {
    _mapController?.animateCamera(
      CameraUpdate.newLatLngZoom(location, 16.0),
    );
  }
  
  Future<void> _openInGoogleMaps(RecyclingCenter center) async {
    final url = 'https://www.google.com/maps/dir/?api=1'
        '&destination=${center.location.latitude},${center.location.longitude}'
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
              if (center.phone.isNotEmpty)
                _buildInfoRow(Icons.phone, center.phone),
              if (center.operatingHours.isNotEmpty)
                _buildInfoRow(Icons.access_time, center.operatingHours),
              if (center.website.isNotEmpty)
                _buildInfoRow(Icons.web, center.website),
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
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.directions),
                      label: const Text('Get Directions'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        padding: const EdgeInsets.all(16),
                      ),
                      onPressed: () => _openInGoogleMaps(center),
                    ),
                  ),
                  const SizedBox(width: 10),
                  IconButton(
                    icon: const Icon(Icons.center_focus_strong),
                    onPressed: () {
                      Navigator.pop(context);
                      _centerMapOnLocation(
                        LatLng(center.location.latitude, center.location.longitude),
                      );
                    },
                    tooltip: 'Center on map',
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.grey[200],
                      padding: const EdgeInsets.all(12),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Recycling Centers'),
          backgroundColor: Colors.green,
          bottom: TabBar(
            tabs: const [
              Tab(icon: Icon(Icons.map), text: 'Map'),
              Tab(icon: Icon(Icons.list), text: 'List'),
            ],
            // Make the tab indicator more noticeable to encourage tab tapping
            indicatorColor: Colors.white,
            indicatorWeight: 3,
            // Add label to clarify navigation method
            labelStyle: const TextStyle(fontWeight: FontWeight.bold),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _initializeMap,
              tooltip: 'Refresh',
            ),
          ],
        ),
        body: TabBarView(
          // Disable swiping between tabs to prevent accidental navigation
          // Users will need to tap the tab bar items to switch views
          physics: const NeverScrollableScrollPhysics(),
          children: [
            // Map View
            _buildMapView(),
            // List View
            _buildListView(),
          ],
        ),
        floatingActionButton: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            FloatingActionButton(
              heroTag: 'fitMarkers',
              onPressed: _fitAllMarkers,
              backgroundColor: Colors.green,
              tooltip: 'Show all centers',
              child: const Icon(Icons.fit_screen),
            ),
            const SizedBox(height: 16),
            FloatingActionButton(
              heroTag: 'currentLocation',
              onPressed: _moveToCurrentLocation,
              backgroundColor: Colors.blue,
              tooltip: 'My location',
              child: const Icon(Icons.my_location),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildMapView() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }
    
    if (_error) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 16),
            Text('Error: $_errorMessage'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _initializeMap,
              child: const Text('Try Again'),
            ),
          ],
        ),
      );
    }
    
    return Stack(
      children: [
        GoogleMap(
          initialCameraPosition: CameraPosition(
            target: _userLatLng ?? const LatLng(10.8505, 76.2711), // Default to Kerala or user location
            zoom: 12,
          ),
          onMapCreated: (GoogleMapController controller) {
            _mapControllerCompleter.complete(controller);
            _mapController = controller;
            _isMapReady = true;
            // Fit all markers once map is created
            Future.delayed(const Duration(milliseconds: 300), _fitAllMarkers);
          },
          markers: _markers,
          myLocationEnabled: true,
          myLocationButtonEnabled: false, // We'll use our own FAB
          mapToolbarEnabled: false,
          zoomControlsEnabled: false, // We'll use gestures for zooming
          // Ensure map gestures are fully enabled
          zoomGesturesEnabled: true,
          scrollGesturesEnabled: true,
          rotateGesturesEnabled: true,
          tiltGesturesEnabled: true,
        ),
        
        // Show selected center details at the bottom if on map view
        if (_selectedCenter != null)
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: _buildCenterDetailsCard(),
          ),
      ],
    );
  }
  
  Widget _buildListView() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }
    
    if (_error) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 16),
            Text('Error: $_errorMessage'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _initializeMap,
              child: const Text('Try Again'),
            ),
          ],
        ),
      );
    }
    
    return _centers.isEmpty
        ? Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.location_off, size: 64, color: Colors.grey),
                const SizedBox(height: 16),
                const Text(
                  'No recycling centers found in your area',
                  style: TextStyle(fontSize: 16),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () => _initializeMap(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                  ),
                  child: const Text('Refresh'),
                ),
              ],
            ),
          )
        : ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: _centers.length,
            itemBuilder: (context, index) {
              final center = _centers[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                child: ListTile(
                  title: Text(center.name),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(center.address),
                      const SizedBox(height: 4),
                      Text(
                        'Accepts: ${center.acceptedMaterials.take(3).join(", ")}${center.acceptedMaterials.length > 3 ? "..." : ""}',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  isThreeLine: true,
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.map, color: Colors.green),
                        onPressed: () {
                          DefaultTabController.of(context).animateTo(0);
                          _centerMapOnLocation(
                            LatLng(center.location.latitude, center.location.longitude),
                          );
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.info_outline, color: Colors.blue),
                        onPressed: () => _showCenterDetails(center),
                      ),
                    ],
                  ),
                  onTap: () => _showCenterDetails(center),
                ),
              );
            },
          );
  }
  
  Widget _buildCenterDetailsCard() {
    return Card(
      margin: const EdgeInsets.all(16),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    _selectedCenter!.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () {
                    setState(() {
                      _selectedCenter = null;
                    });
                  },
                  splashRadius: 24,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(_selectedCenter!.address),
            const SizedBox(height: 4),
            if (_selectedCenter!.phone.isNotEmpty)
              Text('Phone: ${_selectedCenter!.phone}'),
            const SizedBox(height: 4),
            if (_selectedCenter!.operatingHours.isNotEmpty)
              Text('Hours: ${_selectedCenter!.operatingHours}'),
            const SizedBox(height: 12),
            const Text(
              'Accepted Materials:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Wrap(
              spacing: 4,
              runSpacing: 4,
              children: _selectedCenter!.acceptedMaterials.map((material) {
                return Chip(
                  label: Text(material),
                  backgroundColor: Colors.green.shade100,
                  labelStyle: TextStyle(color: Colors.green.shade800),
                  visualDensity: VisualDensity.compact,
                );
              }).toList(),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                if (_selectedCenter!.website.isNotEmpty)
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        final Uri uri = Uri.parse(_selectedCenter!.website);
                        launchUrl(uri);
                      },
                      icon: const Icon(Icons.link),
                      label: const Text('Visit Website'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                      ),
                    ),
                  ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _openInGoogleMaps(_selectedCenter!),
                    icon: const Icon(Icons.directions),
                    label: const Text('Directions'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }
}