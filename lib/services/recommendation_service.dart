// lib/services/recommendation_service.dart
import 'dart:convert';
import 'package:ecopulse_local/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:ecopulse_local/models/recommendation.dart';
import 'package:ecopulse_local/providers/user_provider.dart';

class RecommendationService {
  Future<RecommendationsResponse> getRecommendations(BuildContext context) async {
    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final token = userProvider.user.token;
      
      final response = await http.get(
        Uri.parse('${Constants.uri}/api/recommendations'),
        headers: {
          'Content-Type': 'application/json',
          'x-auth-token': token,
        },
      );

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        return RecommendationsResponse.fromJson(jsonData);
      } else {
        throw Exception('Failed to load recommendations: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching recommendations: $e');
    }
  }
}