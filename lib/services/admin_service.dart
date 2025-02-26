import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import '../models/recyclingcenter.dart';
import '../models/admin.dart';
import '../utils/constants.dart';
import '../utils/utils.dart';
import '../providers/admin_provider.dart';

class AdminService {
  // Admin Authentication
  Future<bool> signInAdmin({
    required BuildContext context,
    required String email,
    required String password,
  }) async {
    try {
      print('Attempting login with email: $email');
      var adminProvider = Provider.of<AdminProvider>(context, listen: false);
      
      http.Response res = await http.post(
        Uri.parse('${Constants.uri}/api/admin/signin'),
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );
      
      print('Response status: ${res.statusCode}');
      print('Response body: ${res.body}');
      
      if (res.statusCode == 200) {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        
        // Parse the response and extract token and admin data
        var responseData = jsonDecode(res.body);
        String token = responseData['token'];
        
        // Create admin object with token
        Admin admin = Admin(
          id: responseData['admin']['id'],
          name: responseData['admin']['name'],
          email: responseData['admin']['email'],
          role: responseData['admin']['role'],
          permissions: Map<String, bool>.from(responseData['admin']['permissions']),
          token: token,
        );
        
        // Save admin info to provider
        adminProvider.setAdmin(jsonEncode(admin.toMap()));
        
        // Save token to shared preferences
        await prefs.setString('admin-token', token);
        return true;
      } else {
        throw jsonDecode(res.body)['msg'] ?? 'An error occurred during admin sign in';
      }
    } catch (e) {
      print('Error details: $e');
      showSnackBar(context, e.toString());
      return false;
    }
  }

  Future<bool> getAdminStatus(BuildContext context) async {
    try {
      var adminProvider = Provider.of<AdminProvider>(context, listen: false);
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('admin-token');
      
      if (token == null || token.isEmpty) {
        return false;
      }

      // Validate admin token
      var tokenRes = await http.post(
        Uri.parse('${Constants.uri}/api/admin/tokenIsValid'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'x-auth-token': token,
        },
      );
      
      if (tokenRes.statusCode != 200) {
        prefs.setString('admin-token', '');
        return false;
      }
      
      var response = jsonDecode(tokenRes.body);
      if (response == true) {
        // If token is valid, get admin data
        http.Response adminRes = await http.get(
          Uri.parse('${Constants.uri}/admin'),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
            'x-auth-token': token,
          },
        );
        
        if (adminRes.statusCode == 200) {
          // Create admin object with fetched data
          var adminData = jsonDecode(adminRes.body);
          Admin admin = Admin(
            id: adminData['id'],
            name: adminData['name'],
            email: adminData['email'],
            role: adminData['role'],
            permissions: Map<String, bool>.from(adminData['permissions']),
            token: token,
          );
          
          // Update admin provider
          adminProvider.setAdmin(jsonEncode(admin.toMap()));
          return true;
        }
      }
      return false;
    } catch (e) {
      print('Error in getAdminStatus: $e');
      return false;
    }
  }

  Future<void> adminLogout(BuildContext context) async {
    try {
      var adminProvider = Provider.of<AdminProvider>(context, listen: false);
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('admin-token', '');
      adminProvider.clearAdmin();
      
      Navigator.pushNamedAndRemoveUntil(
        context, 
        '/home', 
        (route) => false,
      );
    } catch (e) {
      showSnackBar(context, e.toString());
    }
  }

  Future<List<RecyclingCenter>> getRecyclingCenters(BuildContext context) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('admin-token');
      
      if (token == null || token.isEmpty) {
        throw 'Not authenticated. Please login again.';
      }
      
      http.Response res = await http.get(
        Uri.parse('${Constants.uri}/api/admin/recycling-centers'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'x-auth-token': token,
        },
      );
      
      if (res.statusCode != 200) {
        throw jsonDecode(res.body)['msg'] ?? 'Failed to retrieve recycling centers';
      }
      
      List<dynamic> centersJson = jsonDecode(res.body);
      return centersJson.map((center) => RecyclingCenter.fromMap(center)).toList();
    } catch (e) {
      showSnackBar(context, e.toString());
      rethrow;
    }
  }

  Future<void> addRecyclingCenter(BuildContext context, RecyclingCenter center) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('admin-token');
      
      if (token == null || token.isEmpty) {
        throw 'Not authenticated. Please login again.';
      }
      
      http.Response res = await http.post(
        Uri.parse('${Constants.uri}/api/admin/recycling-centers'),
        body: center.toJson(),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'x-auth-token': token,
        },
      );
      
      if (res.statusCode != 201) {
        throw jsonDecode(res.body)['msg'] ?? 'Failed to add recycling center';
      }
    } catch (e) {
      showSnackBar(context, e.toString());
      rethrow;
    }
  }

  Future<void> updateRecyclingCenter(BuildContext context, String id, RecyclingCenter center) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('admin-token');
      
      if (token == null || token.isEmpty) {
        throw 'Not authenticated. Please login again.';
      }
      
      http.Response res = await http.put(
        Uri.parse('${Constants.uri}/api/admin/recycling-centers/$id'),
        body: center.toJson(),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'x-auth-token': token,
        },
      );
      
      if (res.statusCode != 200) {
        throw jsonDecode(res.body)['msg'] ?? 'Failed to update recycling center';
      }
    } catch (e) {
      showSnackBar(context, e.toString());
      rethrow;
    }
  }

  Future<void> deleteRecyclingCenter(BuildContext context, String id) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('admin-token');
      
      if (token == null || token.isEmpty) {
        throw 'Not authenticated. Please login again.';
      }
      
      http.Response res = await http.delete(
        Uri.parse('${Constants.uri}/api/admin/recycling-centers/$id'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'x-auth-token': token,
        },
      );
      
      if (res.statusCode != 200) {
        throw jsonDecode(res.body)['msg'] ?? 'Failed to delete recycling center';
      }
    } catch (e) {
      showSnackBar(context, e.toString());
      rethrow;
    }
  }
}