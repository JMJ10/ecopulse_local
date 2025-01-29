import 'package:flutter/material.dart';
import 'login_screen.dart'; // Import LoginScreen
import 'register_screen.dart'; // Import RegisterScreen

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('ECOPULSE')),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            'ECOPULSE',
            style: TextStyle(
                fontSize: 32, fontWeight: FontWeight.bold, color: Colors.green),
          ),
          SizedBox(height: 10),
          Text(
            'Your go-to app for sustainable living',
            style: TextStyle(fontSize: 18, color: Colors.black54),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 30),
          ElevatedButton(
            onPressed: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => LoginScreen()));
            },
            child: Text('Login'),
          ),
          SizedBox(height: 10),
          ElevatedButton(
            onPressed: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => RegisterScreen()));
            },
            child: Text('Sign Up'),
          ),
        ],
      ),
    );
  }
}
