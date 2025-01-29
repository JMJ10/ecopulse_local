import 'package:flutter/material.dart';
import 'splash_screen.dart';

void main() {
  runApp(EcoPracticesApp());
}

class EcoPracticesApp extends StatelessWidget {
  const EcoPracticesApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Eco Practices Tracking App',
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      home: SplashScreen(),
    );
  }
}
