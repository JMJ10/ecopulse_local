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
    'name': name,
    'address': address,
    'phone': phone,
    'acceptedMaterials': acceptedMaterials,
    'location': {
      'type': 'Point',
      'coordinates': [location.longitude, location.latitude], // Note the order: [longitude, latitude]
    },
    'operatingHours': operatingHours,
    'website': website,
  };
}

  String toJson() => jsonEncode(toMap());

  factory RecyclingCenter.fromMap(Map<String, dynamic> map) {
  // Handle the GeoJSON format from MongoDB
  LatLng locationLatLng;
  if (map['location'] != null) {
    if (map['location']['coordinates'] != null) {
      // GeoJSON Point format: [longitude, latitude]
      try {
        final coordinates = map['location']['coordinates'];
        // GeoJSON stores coordinates as [longitude, latitude]
        locationLatLng = LatLng(
          coordinates[1] is String ? double.parse(coordinates[1]) : coordinates[1].toDouble(),
          coordinates[0] is String ? double.parse(coordinates[0]) : coordinates[0].toDouble(),
        );
      } catch (e) {
        print('Error parsing coordinates: $e');
        locationLatLng = LatLng(0, 0);
      }
    } else if (map['location']['latitude'] != null && map['location']['longitude'] != null) {
      // Original format in your model
      locationLatLng = LatLng(
        map['location']['latitude'] is String 
            ? double.parse(map['location']['latitude']) 
            : map['location']['latitude'],
        map['location']['longitude'] is String 
            ? double.parse(map['location']['longitude']) 
            : map['location']['longitude'],
      );
    } else {
      locationLatLng = LatLng(0, 0);
    }
  } else {
    locationLatLng = LatLng(0, 0);
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