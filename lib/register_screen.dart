import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:eco_pulse/services/auth_services.dart';
import 'package:eco_pulse/reg_success.dart';
import 'package:eco_pulse/login_screen.dart';

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
  bool rememberMe = false;
  final AuthService authService = AuthService();

  void register(BuildContext context) async {
    String name = nameController.text.trim();
    String location = locationController.text.trim();
    String emailOrPhone = emailOrPhoneController.text.trim();
    String password = passwordController.text.trim();

    if (name.isEmpty ||
        location.isEmpty ||
        emailOrPhone.isEmpty ||
        password.isEmpty) {
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
        id: '',
      );

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
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 50),
              IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
              Text(
                'Create Your Account',
                style: GoogleFonts.montserrat(
                  fontSize: 30.0,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xff1F3B3D),
                ),
              ),
              const SizedBox(height: 20),
              buildTextField(nameController, 'Enter your name'),
              const SizedBox(height: 10),
              buildTextField(locationController, 'Location'),
              const SizedBox(height: 10),
              buildTextField(emailOrPhoneController, 'Email or Phone Number',
                  keyboardType: TextInputType.emailAddress),
              const SizedBox(height: 10),
              buildTextField(passwordController, 'Password', obscureText: true),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Checkbox(
                    value: rememberMe,
                    onChanged: (bool? value) {
                      setState(() {
                        rememberMe = value!;
                      });
                    },
                  ),
                  const Text(
                    'Remember Me',
                    style: TextStyle(
                      fontSize: 16.0,
                      color: Color(0xff1F3B3D),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Center(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white.withOpacity(0.4),
                    minimumSize: const Size(200, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  onPressed: () => register(context),
                  child: isLoading
                      ? const CircularProgressIndicator(
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                        )
                      : const Text(
                          'Register',
                          style: TextStyle(
                            color: Color(0xFF1F3B3D),
                            fontSize: 18,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 25),
              Center(
                child: const Text(
                  "_________  Or continue with  _______",
                  style: TextStyle(
                    fontSize: 16.0,
                    color: Color(0xffffffff),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const SizedBox(height: 50),
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
              const SizedBox(height: 70),
              Center(
                child: TextButton(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => LoginScreen()),
                    );
                  },
                  child: const Text(
                    "Already have an account? Login In",
                    style: TextStyle(
                      color: Color(0xff1F3B3D),
                      fontSize: 16.0,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildTextField(TextEditingController controller, String label,
      {TextInputType? keyboardType, bool obscureText = false}) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white),
        filled: true,
        fillColor: Colors.white.withOpacity(0.2),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
      ),
      keyboardType: keyboardType,
      obscureText: obscureText,
    );
  }

  Widget socialLoginButton(String assetPath) {
    return Container(
      width: 70,
      height: 50,
      decoration: BoxDecoration(
        color: const Color(0xff6C9D7A),
        borderRadius: BorderRadius.circular(40),
        border: Border.all(color: Colors.white, width: 2),
      ),
      child: Center(
        child: Image.asset(assetPath, width: 40, height: 30),
      ),
    );
  }
}
