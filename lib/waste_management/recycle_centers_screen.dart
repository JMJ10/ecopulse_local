import 'package:flutter/material.dart';
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

  @override
  void initState() {
    super.initState();
    _loadRecyclingCenters();
  }

  Future<void> _loadRecyclingCenters() async {
    try {
      final centers = await _wasteService.getRecyclingCenters(context);
      setState(() {
        _centers = centers;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load recycling centers: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Recycling Centers'),
        backgroundColor: Colors.green,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(
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
                        onPressed: () {
                          setState(() {
                            _isLoading = true;
                            _errorMessage = null;
                          });
                          _loadRecyclingCenters();
                        },
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : _centers.isEmpty
                  ? const Center(
                      child: Text('No recycling centers found in your area.'),
                    )
                  : RefreshIndicator(
                      onRefresh: _loadRecyclingCenters,
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _centers.length,
                        itemBuilder: (context, index) {
                          final center = _centers[index];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 4,
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    center.name,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      const Icon(Icons.location_on, size: 16, color: Colors.grey),
                                      const SizedBox(width: 4),
                                      Expanded(
                                        child: Text(
                                          center.address,
                                          style: TextStyle(color: Colors.grey[600]),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      const Icon(Icons.phone, size: 16, color: Colors.grey),
                                      const SizedBox(width: 4),
                                      Text(
                                        center.phone ?? 'No phone available',
                                        style: TextStyle(color: Colors.grey[600]),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  const Text(
                                    'Accepted Materials:',
                                    style: TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(height: 4),
                                  Wrap(
                                    spacing: 8,
                                    runSpacing: 8,
                                    children: center.acceptedMaterials.map((material) {
                                      return Chip(
                                        label: Text(material),
                                        backgroundColor: Colors.green.withOpacity(0.1),
                                        labelStyle: const TextStyle(fontSize: 12),
                                      );
                                    }).toList(),
                                  ),
                                  const SizedBox(height: 12),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      TextButton.icon(
                                        icon: const Icon(Icons.directions),
                                        label: const Text('Directions'),
                                        onPressed: () {
                                          // TODO: Implement opening maps
                                        },
                                      ),
                                      TextButton.icon(
                                        icon: const Icon(Icons.info_outline),
                                        label: const Text('More Info'),
                                        onPressed: () {
                                          // TODO: Show more details
                                        },
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
    );
  }
}