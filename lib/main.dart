import 'splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/user_provider.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
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

class EcoPracticesApp extends StatelessWidget {
  const EcoPracticesApp({Key? key}) : super(key: key);
  

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Eco Practices Tracking App',
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      home: const SplashScreen(),
    );
  }
  

}