import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/recyclingcenter.dart';
import '../models/admin.dart';
import '../utils/constants.dart';
import '../utils/utils.dart';

class AdminService {
  // Admin Authentication
  Future<bool> signInAdmin({
    required BuildContext context,
    required String email,
    required String password,
  }) async {
    try {
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

      if (res.statusCode == 200) {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        String token = jsonDecode(res.body)['token'];
        await prefs.setString('admin-token', token);
        return true; // Return true for successful login
      } else {
        throw jsonDecode(res.body)['msg'] ?? 'An error occurred during admin sign in';
      }
    } catch (e) {
      showSnackBar(context, e.toString());
      return false; // Return false for failed login
    }
  }

  Future<bool> getAdminStatus(BuildContext context) async {
    try {
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
      return response == true;
    } catch (e) {
      return false;
    }
  }

  Future<void> adminLogout(BuildContext context) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('admin-token', '');
      
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