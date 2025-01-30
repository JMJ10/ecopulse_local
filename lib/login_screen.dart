import 'package:flutter/material.dart';
import 'dashboard_screen.dart';

class LoginScreen extends StatelessWidget {
  final TextEditingController emailOrPhoneController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  LoginScreen({super.key});

  void login(BuildContext context) {
    String emailOrPhone = emailOrPhoneController.text.trim();
    String password = passwordController.text.trim();

    if (emailOrPhone.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please enter your email or phone number')),
      );
      return;
    }

    if (emailOrPhone.contains('@')) {
      // Email-based login logic
      if (password.isNotEmpty) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => DashboardScreen()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Please enter your password')),
        );
      }
    } else {
      // Phone-based login logic
      if (emailOrPhone.length >= 10) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => DashboardScreen()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Please enter a valid phone number')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Center(
              child: Text(
                'Login',
                style: TextStyle(
                  fontSize: 32.0, // Larger font size
                  fontWeight: FontWeight.bold, // Bold text style
                  color: Colors.green,
                ),
              ),
            ),
            SizedBox(height: 40), // Spacing between the title and input fields
            TextField(
              controller: emailOrPhoneController,
              decoration: InputDecoration(
                labelText: 'Email or Phone Number',
              ),
              keyboardType: TextInputType.emailAddress, // Allows phone and email input
            ),
            TextField(
              controller: passwordController,
              decoration: InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
              ),
              onPressed: () => login(context),
              child: Text('Login'),
            ),
          ],
        ),
      ),
    );
  }
}