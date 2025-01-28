import 'package:flutter/material.dart';
import 'login_screen.dart';

void main() {
  runApp(EcoPracticesApp());
}

class EcoPracticesApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Eco Practices Tracking App',
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      home: LoginScreen(),
    );
  }
}