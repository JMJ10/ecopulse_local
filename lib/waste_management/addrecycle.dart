import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:ecopulse_local/models/recyclingcenter.dart';
import 'package:ecopulse_local/waste_management/waste_service.dart';

class AddRecyclingCenterScreen extends StatefulWidget {
  const AddRecyclingCenterScreen({Key? key, RecyclingCenter? center}) : super(key: key);

  @override
  _AddRecyclingCenterScreenState createState() => _AddRecyclingCenterScreenState();
}

class _AddRecyclingCenterScreenState extends State<AddRecyclingCenterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _addressController = TextEditingController();
  final _phoneController = TextEditingController();
  final _hoursController = TextEditingController();
  final _websiteController = TextEditingController();
  
  final List<String> _acceptedMaterials = [];
  LatLng? _selectedLocation;
  final WasteService _wasteService = WasteService();
  bool _isLoading = false;

  // Predefined list of common recyclable materials
  final List<String> _commonMaterials = [
    'Paper', 'Cardboard', 'Plastic', 'Glass', 'Metal',
    'Electronics', 'Batteries', 'Oil', 'Tires', 'Textiles'
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
    _hoursController.dispose();
    _websiteController.dispose();
    super.dispose();
  }

  Future<void> _saveRecyclingCenter() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedLocation == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a location on the map')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final newCenter = RecyclingCenter(
        id: '', // Will be set by the backend
        name: _nameController.text,
        address: _addressController.text,
        phone: _phoneController.text,
        acceptedMaterials: List.from(_acceptedMaterials),
        location: LatLng(_selectedLocation!.latitude, _selectedLocation!.longitude),
        operatingHours: _hoursController.text,
        website: _websiteController.text,
      );
      
      await _wasteService.addRecyclingCenter(context, newCenter);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Recycling center added successfully')),
        );
        Navigator.pop(context, true); // Return true to indicate success
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error adding recycling center: $e')),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Recycling Center'),
        backgroundColor: Colors.green,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'Center Name *',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) =>
                          value?.isEmpty ?? true ? 'Name is required' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _addressController,
                      decoration: const InputDecoration(
                        labelText: 'Address *',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) =>
                          value?.isEmpty ?? true ? 'Address is required' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _phoneController,
                      decoration: const InputDecoration(
                        labelText: 'Phone Number',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.phone,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _hoursController,
                      decoration: const InputDecoration(
                        labelText: 'Operating Hours',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _websiteController,
                      decoration: const InputDecoration(
                        labelText: 'Website',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.url,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Accepted Materials *',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _commonMaterials.map((material) {
                        final isSelected = _acceptedMaterials.contains(material);
                        return FilterChip(
                          label: Text(material),
                          selected: isSelected,
                          onSelected: (selected) {
                            setState(() {
                              if (selected) {
                                _acceptedMaterials.add(material);
                              } else {
                                _acceptedMaterials.remove(material);
                              }
                            });
                          },
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Select Location *',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      height: 200,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: GoogleMap(
                        initialCameraPosition: const CameraPosition(
                          target: LatLng(10.8505, 76.2711), // Default to Kerala
                          zoom: 12,
                        ),
                        onTap: (LatLng position) {
                          setState(() => _selectedLocation = position);
                        },
                        markers: _selectedLocation == null
                            ? {}
                            : {
                                Marker(
                                  markerId: const MarkerId('selected_location'),
                                  position: _selectedLocation!,
                                ),
                              },
                      ),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: _saveRecyclingCenter,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        padding: const EdgeInsets.all(16),
                      ),
                      child: const Text('Save Recycling Center'),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}