import 'dart:convert';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class RecyclingCenter {
  final String id;
  final String name;
  final String address;
  final String? phone;
  final List<String> acceptedMaterials;
  final LatLng location;
  final String? operatingHours;
  final String? website;

  RecyclingCenter({
    required this.id,
    required this.name,
    required this.address,
    this.phone,
    required this.acceptedMaterials,
    required this.location,
    this.operatingHours,
    this.website,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'address': address,
      'phone': phone,
      'acceptedMaterials': acceptedMaterials,
      'location': location != null 
          ? {
              'type': 'Point',
              'coordinates': [location!.longitude, location!.latitude]
            }
          : null,
      'operatingHours': operatingHours,
      'website': website,
    };
  }

  factory RecyclingCenter.fromMap(Map<String, dynamic> map) {
    final locationData = map['location'];
    LatLng? location;
    
    if (locationData != null && locationData['coordinates'] is List) {
      final coords = locationData['coordinates'] as List;
      if (coords.length == 2) {
        // MongoDB stores as [longitude, latitude]
        location = LatLng(coords[1].toDouble(), coords[0].toDouble());
      }
    }

    return RecyclingCenter(
      id: map['_id'] ?? '',
      name: map['name'] ?? '',
      address: map['address'] ?? '',
      phone: map['phone'],
      acceptedMaterials: List<String>.from(map['acceptedMaterials'] ?? []),
      location: location ?? LatLng(0, 0),
      operatingHours: map['operatingHours'],
      website: map['website'],
    );
  }

  String toJson() => json.encode(toMap());

  factory RecyclingCenter.fromJson(String source) => 
      RecyclingCenter.fromMap(json.decode(source));
}