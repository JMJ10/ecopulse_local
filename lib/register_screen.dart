import 'package:flutter/material.dart';
import 'package:ecopulse_local/dashboard_screen.dart';
import 'package:ecopulse_local/services/auth_services.dart';
import 'package:ecopulse_local/reg_success.dart';

class RegisterScreen extends StatefulWidget {
  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController locationController = TextEditingController();
  final TextEditingController emailOrPhoneController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool isLoading = false;
  final AuthService authService = AuthService();

  void register(BuildContext context) async {
    String name = nameController.text.trim();
    String location = locationController.text.trim();
    String emailOrPhone = emailOrPhoneController.text.trim();
    String password = passwordController.text.trim();

    if (name.isEmpty || location.isEmpty || emailOrPhone.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all fields')),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      await authService.signUpUser(
        context: context,
        email: emailOrPhone,
        password: password,
        name: name,
        location: location,
        id: '',      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => RegistrationSuccessScreen()),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF6C9D7A),
      body: Stack(
        children: [
          Positioned(
            top: 50,
            left: 20,
            child: const Text(
              'Create Your Account',
              style: TextStyle(
                fontSize: 24.0,
                fontWeight: FontWeight.w600,
                color: Color(0xff1F3B3D),
              ),
            ),
          ),Align(
              alignment: Alignment.topLeft,
              child: IconButton(
                icon: Icon(Icons.arrow_back),
                onPressed: () {
                  Navigator.pop(context);
                  },
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
                buildTextField(emailOrPhoneController, 'Email or Phone Number', keyboardType: TextInputType.emailAddress),
                const SizedBox(height: 10),
                buildTextField(passwordController, 'Password', obscureText: true),
                const SizedBox(height: 20),
                Center(
                  child: Opacity(
                    opacity: 0.9,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white.withOpacity(0.2),
                      ),
                      onPressed: () => register(context),
                      child: isLoading
                          ? CircularProgressIndicator(color: Colors.white)
                          : const Text('Register', style: TextStyle(color: Color(0xFF1F3B3D))),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    socialLoginButton('assets/facebook.png'),
                    const SizedBox(width: 10),
                    socialLoginButton('assets/google.png'),
                    const SizedBox(width: 10),
                    socialLoginButton('assets/whatsapp.png'),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildTextField(TextEditingController controller, String label, {TextInputType? keyboardType, bool obscureText = false}) {
    return Container(
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
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

  Widget socialLoginButton(String assetPath) {
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        color: const Color(0xff6C9D7A),
        borderRadius: BorderRadius.circular(40),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            spreadRadius: 2,
            blurRadius: 5,
          ),
        ],
      ),
      child: Center(
        child: Image.asset(
          assetPath,
          width: 30,
          height: 30,
        ),
      ),
    );
  }
}

