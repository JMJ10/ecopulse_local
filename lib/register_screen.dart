import 'package:flutter/material.dart';
import 'dashboard_screen.dart';

class RegisterScreen extends StatelessWidget {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController locationController = TextEditingController();
  final TextEditingController emailOrPhoneController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  RegisterScreen({super.key});

  void register(BuildContext context) {
    String name = nameController.text.trim();
    String location = locationController.text.trim();
    String emailOrPhone = emailOrPhoneController.text.trim();
    String password = passwordController.text.trim();

    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your name')),
      );
      return;
    }

    if (location.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your location')),
      );
      return;
    }

    if (emailOrPhone.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Please enter your email or phone number')),
      );
      return;
    }

    if (emailOrPhone.contains('@')) {
      if (password.isNotEmpty) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => DashboardScreen()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please enter your password')),
        );
      }
    } else {
      if (emailOrPhone.length >= 10) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => DashboardScreen()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please enter a valid phone number')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF6C9D7A),
      body: Stack(
        children: [
          Positioned(
            top: 50, // Adjust the distance from the top
            left: 20, // Adjust the distance from the left
            child: Text(
              'Create Your Account',
              style: const TextStyle(
                fontSize: 24.0,
                fontWeight: FontWeight.w600,
                color: Colors.green,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 100.0, left: 16.0, right: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                buildTextField(nameController, 'Name'),
                const SizedBox(height: 10),
                buildTextField(locationController, 'Location'),
                const SizedBox(height: 10),
                buildTextField(emailOrPhoneController, 'Email or Phone Number',
                    keyboardType: TextInputType.emailAddress),
                const SizedBox(height: 10),
                buildTextField(passwordController, 'Password',
                    obscureText: true),
                const SizedBox(height: 20),
                Center(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                    ),
                    onPressed: () => register(context),
                    child: const Text('Register'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildTextField(TextEditingController controller, String label,
      {TextInputType? keyboardType, bool obscureText = false}) {
    return Container(
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 2,
            blurRadius: 5,
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: InputBorder.none,
        ),
        keyboardType: keyboardType,
        obscureText: obscureText,
      ),
    );
  }
}
