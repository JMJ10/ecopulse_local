import 'dart:convert';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:ecopulse_local/utils/utils.dart';
import 'package:ecopulse_local/utils/constants.dart';
import 'package:ecopulse_local/models/user.dart';
import 'package:provider/provider.dart';
import 'package:ecopulse_local/providers/user_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
        token: '',
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
  Future<bool> signInUser({
  required BuildContext context,
  required String email,
  required String password,
}) async {
  try {
    var userProvider = Provider.of<UserProvider>(context, listen: false);
    
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

    if (res.statusCode == 200) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      userProvider.setUser(res.body);
      await prefs.setString('x-auth-token', jsonDecode(res.body)['token']);
      return true; // Return true for successful login
    } else {
      throw jsonDecode(res.body)['msg'] ?? 'An error occurred during sign in';
    }
  } catch (e) {
    showSnackBar(context, e.toString());
    return false; // Return false for failed login

  }
}


   Future<bool> getUser(BuildContext context) async {
  try {
    var userProvider = Provider.of<UserProvider>(context, listen: false);
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('x-auth-token');

    print("Retrieved token from SharedPreferences: $token");


    if(token == null || token.isEmpty) {
      print("No token found in SharedPreferences");
      prefs.setString('x-auth-token', '');
      return false;
    }

    var tokenRes = await http.post(
      Uri.parse('${Constants.uri}/tokenIsValid'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'x-auth-token': token,
      },
    );

    if(tokenRes.statusCode!=200){
      print("Token validation failed with status code: ${tokenRes.statusCode}");
      prefs.setString('x-auth-token', '');
      return false;
    }
    
    try {
      var response = jsonDecode(tokenRes.body);
      print("Token validation response: $response");
      if(response == true) {
        http.Response userRes = await http.get(
          Uri.parse('${Constants.uri}/api/user'),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
            'x-auth-token': token,
          },
        );
          
        if(userRes.statusCode!=200){
          print("Failed to get user data, status code: ${userRes.statusCode}");
          prefs.setString('x-auth-token', '');
          return false;
        }

        try {
          userProvider.setUser(userRes.body);
          print("Successfully retrieved and set user data");
          return true;
        }
        catch (e){
            print("Error parsing user data: ${userRes.body}");
            print("Exception: $e");
            prefs.setString('x-auth-token', '');
            return false;
        }
      }
      else{
        print("Token validation returned false");
        prefs.setString('x-auth-token', '');
        return false;
      }
    } catch (e) {
      print("Error parsing token response: ${tokenRes.body}");
      print("Exception: $e");
      prefs.setString('x-auth-token', '');
      return false;
    }
  }
  catch (e) {
    print("Error in getUser: $e");
    return false;
  }
}
}
