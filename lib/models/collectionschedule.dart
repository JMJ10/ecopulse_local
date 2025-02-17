import 'dart:convert';

class CollectionSchedule {
  final String id;
  final String location;
  final DateTime date;
  final String wasteType;
  final String? notes;

  CollectionSchedule({
    required this.id,
    required this.location,
    required this.date,
    required this.wasteType,
    this.notes,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'location': location,
      'date': date.toIso8601String(),
      'wasteType': wasteType,
      'notes': notes,
    };
  }

  factory CollectionSchedule.fromMap(Map<String, dynamic> map) {
    return CollectionSchedule(
      id: map['_id'] ?? '',
      location: map['location'] ?? '',
      wasteType: map['wasteType'] ?? '',
      date: DateTime.parse(map['date'] ?? DateTime.now().toIso8601String()),
      notes: map['notes'],
    );
  }

  String toJson() => json.encode(toMap());

  factory CollectionSchedule.fromJson(String source) => CollectionSchedule.fromMap(json.decode(source));
}