import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:ecopulse_local/utils/utils.dart';
import 'package:ecopulse_local/utils/constants.dart';
import 'package:ecopulse_local/models/wastelog.dart';
import 'package:ecopulse_local/models/recyclingcenter.dart';
import 'package:ecopulse_local/models/collectionschedule.dart';
import 'package:provider/provider.dart';
import 'package:ecopulse_local/providers/user_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class WasteService {
  // Log waste
  Future<void> logWaste(BuildContext context, WasteLog log) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('x-auth-token');
      
      if (token == null || token.isEmpty) {
        throw 'Not authenticated. Please login again.';
      }
      
      http.Response res = await http.post(
        Uri.parse('${Constants.uri}/api/waste/log'),
        body: log.toJson(),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'x-auth-token': token,
        },
      );
      
      if (res.statusCode != 200 && res.statusCode != 201) {
        throw jsonDecode(res.body)['msg'] ?? 'An error occurred while logging waste';
      }
    } catch (e) {
      showSnackBar(context, e.toString());
      rethrow;
    }
  }
  
  // Get waste logs for the current user
  Future<List<WasteLog>> getWasteLogs(BuildContext context) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('x-auth-token');
      
      if (token == null || token.isEmpty) {
        throw 'Not authenticated. Please login again.';
      }
      
      http.Response res = await http.get(
        Uri.parse('${Constants.uri}/api/waste/logs'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'x-auth-token': token,
        },
      );
      
      if (res.statusCode != 200) {
        throw jsonDecode(res.body)['msg'] ?? 'Failed to retrieve waste logs';
      }
      
      List<dynamic> logsJson = jsonDecode(res.body);
      return logsJson.map((log) => WasteLog.fromMap(log)).toList();
    } catch (e) {
      showSnackBar(context, e.toString());
      rethrow;
    }
  }
  
  // Get recycling centers
  Future<List<RecyclingCenter>> getRecyclingCenters(
  BuildContext context, {
  double? latitude,
  double? longitude,
}) async {
  try {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('x-auth-token');
    
    if (token == null || token.isEmpty) {
      throw 'Not authenticated. Please login again.';
    }
    
    Uri uri = Uri.parse('${Constants.uri}/api/waste/recycling-centers');
    
    // Add location parameters if available
    if (latitude != null && longitude != null) {
      uri = uri.replace(queryParameters: {
        'latitude': latitude.toString(),
        'longitude': longitude.toString(),
        'radius': '10', // Default radius in km
      });
    }
    
    http.Response res = await http.get(
      uri,
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
  
  // Get collection schedules
  Future<List<CollectionSchedule>> getCollectionSchedules(BuildContext context) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('x-auth-token');
      String? userLocation = Provider.of<UserProvider>(context, listen: false).user.location;
      
      if (token == null || token.isEmpty) {
        throw 'Not authenticated. Please login again.';
      }
      
      Uri uri = Uri.parse('${Constants.uri}/api/waste/collection-schedules');
      if (userLocation != null && userLocation.isNotEmpty) {
        uri = uri.replace(queryParameters: {'location': userLocation});
      }
      
      http.Response res = await http.get(
        uri,
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'x-auth-token': token,
        },
      );
      
      if (res.statusCode != 200) {
        throw jsonDecode(res.body)['msg'] ?? 'Failed to retrieve collection schedules';
      }
      
      List<dynamic> schedulesJson = jsonDecode(res.body);
      return schedulesJson.map((schedule) => CollectionSchedule.fromMap(schedule)).toList();
    } catch (e) {
      showSnackBar(context, e.toString());
      rethrow;
    }
  }
}