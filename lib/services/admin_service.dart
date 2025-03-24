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
  // Use a consistent token key name throughout the app
  static const String _adminTokenKey = 'admin-token';
  static const String _adminNameKey = 'admin_name';

  // Admin Authentication
  Future<bool> signInAdmin({
    required BuildContext context,
    required String email,
    required String password,
  }) async {
    try {
      print('Attempting admin login with email: $email');
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
        
        // Parse the response
        var responseData = jsonDecode(res.body);
        
        // Store the raw response in the provider (similar to how user auth works)
        adminProvider.setAdmin(res.body);
        
        // Save token to shared preferences - use consistent key
        await prefs.setString(_adminTokenKey, responseData['token']);
        await prefs.setString(_adminNameKey, responseData['admin']['name']);
        
        print('Admin token saved: ${responseData['token'].substring(0, 10)}...');
        return true;
      } else {
        throw jsonDecode(res.body)['msg'] ?? 'An error occurred during admin sign in';
      }
    } catch (e) {
      print('Error details in signInAdmin: $e');
      showSnackBar(context, e.toString());
      return false;
    }
  }

  Future<bool> getAdminStatus(BuildContext context) async {
    try {
      var adminProvider = Provider.of<AdminProvider>(context, listen: false);
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString(_adminTokenKey);
      
      print("Retrieved admin token from SharedPreferences: ${token != null ? (token.length > 10 ? token.substring(0, 10) + '...' : token) : 'null'}");
      
      if (token == null || token.isEmpty) {
        print("No admin token found in SharedPreferences");
        await prefs.setString(_adminTokenKey, '');
        return false;
      }

      // Validate admin token
      var tokenRes = await http.post(
        Uri.parse('${Constants.uri}/api/admin/tokenIsValid'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'admin-token': token,
        },
      );
      
      print("Admin token validation response status: ${tokenRes.statusCode}");
      
      if (tokenRes.statusCode != 200) {
        print("Admin token validation failed with status: ${tokenRes.statusCode}");
        await prefs.setString(_adminTokenKey, '');
        return false;
      }
      
      try {
        var response = jsonDecode(tokenRes.body);
        print("Admin token validation response: $response");
        
        if (response == true) {
          // Token is valid, get admin data
          http.Response adminRes = await http.get(
            Uri.parse('${Constants.uri}/api/admin'),
            headers: <String, String>{
              'Content-Type': 'application/json; charset=UTF-8',
              'admin-token': token,
            },
          );
          
          print("Admin data response status: ${adminRes.statusCode}");
          print("Admin data response body: ${adminRes.body}");
          
          if (adminRes.statusCode == 200) {
            // Set admin data directly from response (matching user auth pattern)
            adminProvider.setAdmin(adminRes.body);
            print("Successfully retrieved and set admin data");
            return true;
          } else {
            print("Failed to get admin data, status code: ${adminRes.statusCode}");
            await prefs.setString(_adminTokenKey, '');
            return false;
          }
        } else {
          print("Admin token validation returned false");
          await prefs.setString(_adminTokenKey, '');
          return false;
        }
      } catch (e) {
        print("Error parsing admin token response: ${tokenRes.body}");
        print("Exception in token validation: $e");
        await prefs.setString(_adminTokenKey, '');
        return false;
      }
    } catch (e) {
      print('General error in getAdminStatus: $e');
      return false;
    }
  }

  Future<void> adminLogout(BuildContext context) async {
    try {
      var adminProvider = Provider.of<AdminProvider>(context, listen: false);
      SharedPreferences prefs = await SharedPreferences.getInstance();
      
      print("Logging out admin user");
      await prefs.setString(_adminTokenKey, '');
      await prefs.remove(_adminNameKey);
      adminProvider.clearAdmin();
      
      Navigator.pushNamedAndRemoveUntil(
        context, 
        '/home', 
        (route) => false,
      );
      
      print("Admin logout complete");
    } catch (e) {
      print("Error in adminLogout: $e");
      showSnackBar(context, e.toString());
    }
  }

  Future<List<RecyclingCenter>> getRecyclingCenters(BuildContext context) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString(_adminTokenKey);
      
      if (token == null || token.isEmpty) {
        throw 'Not authenticated. Please login again.';
      }
      
      http.Response res = await http.get(
        Uri.parse('${Constants.uri}/api/admin/recycling-centers'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'admin-token': token,
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
      String? token = prefs.getString(_adminTokenKey);
      
      if (token == null || token.isEmpty) {
        throw 'Not authenticated. Please login again.';
      }
      
      // Debug log
      print('Using admin token for request: ${token.length > 10 ? token.substring(0, 10) + '...' : token}');
      
      final response = await http.post(
        Uri.parse('${Constants.uri}/api/admin/recycling-centers'),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'admin-token': token,
        },
        body: jsonEncode(center.toMap()),
      );
      
      print('Response status: ${response.statusCode}');
      
      if (response.statusCode == 201) {
        showSnackBar(context, 'Recycling center added successfully');
      } else {
        final errorMsg = jsonDecode(response.body)['msg'] ?? 'Failed to add recycling center';
        throw errorMsg;
      }
    } catch (e) {
      print('Error in addRecyclingCenter: $e');
      showSnackBar(context, 'Error: $e');
      rethrow;
    }
  }

  Future<void> updateRecyclingCenter(BuildContext context, String id, RecyclingCenter center) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString(_adminTokenKey);
      
      if (token == null || token.isEmpty) {
        throw 'Not authenticated. Please login again.';
      }
      
      http.Response res = await http.put(
        Uri.parse('${Constants.uri}/api/admin/recycling-centers/$id'),
        body: jsonEncode(center.toMap()),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'admin-token': token,
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
      String? token = prefs.getString(_adminTokenKey);
      
      if (token == null || token.isEmpty) {
        throw 'Not authenticated. Please login again.';
      }
      
      http.Response res = await http.delete(
        Uri.parse('${Constants.uri}/api/admin/recycling-centers/$id'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'admin-token': token,
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