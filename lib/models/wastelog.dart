import 'dart:convert';

class WasteLog {
  final String id;
  final String userId;
  final String wasteType;
  final double quantity;
  final String units;
  final String? notes;
  final DateTime logDate;

  WasteLog({
    required this.id,
    required this.userId,
    required this.wasteType,
    required this.quantity,
    required this.units,
    this.notes,
    required this.logDate,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'wasteType': wasteType,
      'quantity': quantity,
      'units': units,
      'notes': notes,
      'logDate': logDate.toIso8601String(),
    };
  }

  factory WasteLog.fromMap(Map<String, dynamic> map) {
    return WasteLog(
      id: map['_id'] ?? '',
      userId: map['userId'] ?? '',
      wasteType: map['wasteType'] ?? '',
      quantity: map['quantity']?.toDouble() ?? 0.0,
      units: map['units'] ?? 'kg',
      notes: map['notes'],
      logDate: DateTime.parse(map['logDate'] ?? DateTime.now().toIso8601String()),
    );
  }

  String toJson() => json.encode(toMap());

  factory WasteLog.fromJson(String source) => WasteLog.fromMap(json.decode(source));
}