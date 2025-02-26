import 'dart:convert';
import 'package:flutter/material.dart';
import '../models/admin.dart';

class AdminProvider extends ChangeNotifier {
  Admin _admin = Admin(
    id: '',
    name: '',
    email: '',
    role: '',
    permissions: {},
    token: '',
  );

  Admin get admin => _admin;

  void setAdmin(String adminJson) {
    if (adminJson.isNotEmpty) {
      _admin = Admin.fromJson(adminJson);
      notifyListeners();
    }
  }

  void clearAdmin() {
    _admin = Admin(
      id: '',
      name: '',
      email: '',
      role: '',
      permissions: {},
      token: '',
    );
    notifyListeners();
  }
}