import 'dart:convert';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class RecyclingCenter {
  final String id;
  final String name;
  final String address;
  final String phone;
  final List<String> acceptedMaterials;
  final LatLng location;
  final String operatingHours;
  final String website;

  RecyclingCenter({
    required this.id,
    required this.name,
    required this.address,
    required this.phone,
    required this.acceptedMaterials,
    required this.location,
    required this.operatingHours,
    required this.website,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'address': address,
      'phone': phone,
      'acceptedMaterials': acceptedMaterials,
      'location': {
        'latitude': location.latitude,
        'longitude': location.longitude,
      },
      'operatingHours': operatingHours,
      'website': website,
    };
  }

  String toJson() => jsonEncode(toMap());

  factory RecyclingCenter.fromMap(Map<String, dynamic> map) {
    // Handle different location formats from API
    LatLng locationLatLng;
    if (map['location'] is Map) {
      locationLatLng = LatLng(
        map['location']['latitude'] is String 
            ? double.parse(map['location']['latitude']) 
            : map['location']['latitude'],
        map['location']['longitude'] is String 
            ? double.parse(map['location']['longitude']) 
            : map['location']['longitude'],
      );
    } else {
      // Handle potential alternate format
      locationLatLng = LatLng(0, 0); // Default if location is missing
    }

    return RecyclingCenter(
      id: map['_id'] ?? map['id'] ?? '',
      name: map['name'] ?? '',
      address: map['address'] ?? '',
      phone: map['phone'] ?? '',
      acceptedMaterials: List<String>.from(map['acceptedMaterials'] ?? []),
      location: locationLatLng,
      operatingHours: map['operatingHours'] ?? '',
      website: map['website'] ?? '',
    );
  }

  factory RecyclingCenter.fromJson(String source) => 
      RecyclingCenter.fromMap(jsonDecode(source));
}