// models/admin.dart
import 'dart:convert';

class Admin {
  final String id;
  final String name;
  final String email;
  final String role;
  final Map<String, bool> permissions;
  final String token;

  Admin({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    required this.permissions,
    required this.token,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'role': role,
      'permissions': permissions,
      'token': token,
    };
  }

  factory Admin.fromMap(Map<String, dynamic> map) {
    return Admin(
      id: map['_id'] ?? '',
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      role: map['role'] ?? 'admin',
      permissions: Map<String, bool>.from(map['permissions'] ?? {}),
      token: map['token'] ?? '',
    );
  }

  String toJson() => json.encode(toMap());

  factory Admin.fromJson(String source) => Admin.fromMap(json.decode(source));

  Admin copyWith({
    String? id,
    String? name,
    String? email,
    String? role,
    Map<String, bool>? permissions,
    String? token,
  }) {
    return Admin(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      role: role ?? this.role,
      permissions: permissions ?? this.permissions,
      token: token ?? this.token,
    );
  }
}