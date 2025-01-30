import 'dart:convert';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:ecopulse_local/utils/utils.dart';
import 'package:ecopulse_local/utils/constants.dart';
import 'package:ecopulse_local/models/user.dart';

class AuthService {
  // sign up user
  Future<void> signUpUser({
    required BuildContext context,
    required String id,
     required String name,
    required String email,
    required String location,
    required String password,
  }) async {
    try {
      User user = User(
        id: id,
        name: name,
        email: email,
        location: location,
        password: password,
      );

      http.Response res = await http.post(
        Uri.parse('${Constants.uri}/api/signup'),
        body: user.toJson(),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );

      httpErrorHandle(
        response: res,
        context: context,
        onSuccess: () {
          showSnackBar(context, 'Account created! Please login with the same credentials.');
        },
      );
    } catch (e) {
      showSnackBar(context, e.toString());
    }
  }

  // sign in user
  /*Future<void> signInUser({
    required BuildContext context,
    required String email,
    required String password,
    required String name,
    required String location,
  }) async {
    try {
      http.Response res = await http.post(
        Uri.parse('${Constants.uri}/api/signin'),
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );

      httpErrorHandle(
        response: res,
        context: context,
        onSuccess: () {
          // Add token handling here if needed
          Navigator.pushReplacementNamed(context, '/dashboard');
        },
      );
    } catch (e) {
      showSnackBar(context, e.toString());
    }
  }
  */
}
