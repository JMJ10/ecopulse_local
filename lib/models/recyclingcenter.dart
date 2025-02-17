import 'dart:convert';

class RecyclingCenter {
  final String id;
  final String name;
  final String address;
  final String? phone;
  final List<String> acceptedMaterials;
  final double? latitude;
  final double? longitude;

  RecyclingCenter({
    required this.id,
    required this.name,
    required this.address,
    this.phone,
    required this.acceptedMaterials,
    this.latitude,
    this.longitude,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'address': address,
      'phone': phone,
      'acceptedMaterials': acceptedMaterials,
      'latitude': latitude,
      'longitude': longitude,
    };
  }

  factory RecyclingCenter.fromMap(Map<String, dynamic> map) {
    return RecyclingCenter(
      id: map['_id'] ?? '',
      name: map['name'] ?? '',
      address: map['address'] ?? '',
      phone: map['phone'],
      acceptedMaterials: List<String>.from(map['acceptedMaterials'] ?? []),
      latitude: map['latitude']?.toDouble(),
      longitude: map['longitude']?.toDouble(),
    );
  }

  String toJson() => json.encode(toMap());

  factory RecyclingCenter.fromJson(String source) => RecyclingCenter.fromMap(json.decode(source));
}