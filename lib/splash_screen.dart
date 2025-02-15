import 'dashboard_screen.dart';
import 'services/auth_services.dart';
import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'dart:async';
import 'package:provider/provider.dart';
import 'package:ecopulse_local/providers/user_provider.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}):super (key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {

  final AuthService user = AuthService();

  @override
  void initState() {
    super.initState();
    checkUserAuth();
  }

  Future<void> checkUserAuth() async {
    try{
      await Future.delayed(Duration(seconds: 3));
  
      if (!mounted) return;

      print("Checking user authentication...");
      bool isAuthenticated = await AuthService().getUser(context);  
      print("Authentication check result: $isAuthenticated");

      if (!mounted) return;

      if (isAuthenticated) {
        print("User is authenticated, navigating to Dashboard");
        Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => DashboardScreen()),
      );
    }
    else {
      print("User is not authenticated, navigating to Home");
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomeScreen()),
      );
    }
  }
  catch (e) {
    print("Error in checkUserAuth: $e");
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomeScreen()),
      );
    }
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green,
      body: Center(
        child: Text(
          'Eco Practices',
          style: TextStyle(
              fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ),
    );
  }
}
