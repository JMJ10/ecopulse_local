import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'models/recyclingcenter.dart';
import 'services/admin_service.dart';
import 'waste_management/addrecycle.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({Key? key}) : super(key: key);

  @override
  _AdminDashboardState createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  final AdminService _adminService = AdminService();
  List<RecyclingCenter> _centers = [];
  bool _isLoading = true;
  String? _error;
  Set<Marker> _markers = {};
  GoogleMapController? _mapController;

  @override
  void initState() {
    super.initState();
    _loadRecyclingCenters();
  }

  Future<void> _loadRecyclingCenters() async {
    try {
      setState(() => _isLoading = true);
      final centers = await _adminService.getRecyclingCenters(context);
      
      final markers = centers.map((center) => Marker(
        markerId: MarkerId(center.id),
        position: LatLng(
          center.location.latitude,
          center.location.longitude,
        ),
        infoWindow: InfoWindow(
          title: center.name,
          snippet: center.address,
        ),
        onTap: () => _showCenterDetails(center),
      )).toSet();

      setState(() {
        _centers = centers;
        _markers = markers;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  void _showCenterDetails(RecyclingCenter center) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(center.name, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            Text(center.address),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () => _editCenter(center),
                  child: const Text('Edit'),
                ),
                ElevatedButton(
                  onPressed: () => _deleteCenter(center),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                  child: const Text('Delete'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _editCenter(RecyclingCenter center) async {
    // Navigate to edit screen
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddRecyclingCenterScreen(center: center),
      ),
    );

    if (result == true) {
      _loadRecyclingCenters();
    }
  }

  Future<void> _deleteCenter(RecyclingCenter center) async {
    try {
      await _adminService.deleteRecyclingCenter(context, center.id);
      Navigator.pop(context); // Close bottom sheet
      _loadRecyclingCenters();
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Recycling center deleted successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error deleting center: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadRecyclingCenters,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text(_error!))
              : GoogleMap(
                  initialCameraPosition: const CameraPosition(
                    target: LatLng(10.8505, 76.2711), // Default to Kerala
                    zoom: 10,
                  ),
                  markers: _markers,
                  onMapCreated: (controller) => _mapController = controller,
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddRecyclingCenterScreen(),
            ),
          );

          if (result == true) {
            _loadRecyclingCenters();
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}