import 'splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:ecopulse_local/dashboard_screen.dart';
import 'package:ecopulse_local/home_screen.dart';
import 'package:ecopulse_local/models/user.dart';
import 'package:ecopulse_local/services/auth_services.dart';

import 'package:ecopulse_local/providers/user_provider.dart';

void main() {
  runApp(
    MultiProvider(
      providers:[
        ChangeNotifierProvider(create: (context) => UserProvider()),
      ],
      child:
    EcoPracticesApp(),
    ),
  );
}

class EcoPracticesApp extends StatefulWidget {
  const EcoPracticesApp({Key? key}) : super(key: key);
  
  @override
  State<EcoPracticesApp> createState() =>_EcoPracticesAppState();
}


class _EcoPracticesAppState extends State<EcoPracticesApp> {

  final AuthService authService = AuthService();

  @override
  void initState() {
    super.initState();
    authService.getUser(context);
  }


  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Eco Practices Tracking App',
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      home: Provider.of<UserProvider>(context,listen: false).user.token.isEmpty ? SplashScreen() : DashboardScreen(),
    );
  }
  

}