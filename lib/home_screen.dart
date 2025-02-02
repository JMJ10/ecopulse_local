import 'package:flutter/material.dart';
import 'login_screen.dart'; // Import LoginScreen
import 'register_screen.dart'; // Import RegisterScreen

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(kToolbarHeight),
        child: SafeArea(
          child: AppBar(
            backgroundColor:
                Color(0xFF6C9D7A), // Set the app bar color to match background
            elevation: 0, // Optional: Removes app bar shadow for a cleaner look
          ),
        ),
      ),
      backgroundColor: Color(0xFF6C9D7A), // Set background color here
      body: Center(
        // Wrap Column inside Center widget
        child: Column(
          mainAxisSize: MainAxisSize.min, // Centers the Column content
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text(
              'Welcome to',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                fontFamily: 'MuktaMahee',
                color: Color(0xff67460E),
              ),
            ),
            // Text widget with the Monte Carlo font applied
            const Text(
              'Eco Pulse',
              style: TextStyle(
                fontSize: 80,
                fontWeight: FontWeight.bold,
                fontFamily: 'MonteCarlo', // Apply the Monte Carlo font
                color: Color(0xff67460E),
              ),
            ),
            const SizedBox(height: 110),
            const Text(
              'Empowering You to Live Green, One Step at a Time. ',
              style: TextStyle(
                  fontSize: 18, color: Color.fromARGB(255, 255, 255, 255)),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 60),
            SizedBox(
              width: 200, // Set a fixed button width
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => LoginScreen()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      Color(0xFF2D5C5A), // Set the button background color
                  foregroundColor: Colors.white, // Set the text color to white
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(14), // Set border radius
                    side: BorderSide(
                      color: Color(0xFF2D5C5A), // Set border color
                      width: 2, // Set border width
                    ),
                  ),
                ),
                child: const Text('Login', style: TextStyle()),
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: 200, // Set a fixed button width
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => RegisterScreen()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      Color(0xFF6C9D7A), // Set the button background color
                  foregroundColor:
                      Color(0xFF1F3B3D), // Set the text color to white
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(14), // Set border radius
                    side: BorderSide(
                      color: Color(0xFF1F3B3D), // Set border color
                      width: 1, // Set border width
                    ),
                  ),
                ),
                child: const Text('Sign Up'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
