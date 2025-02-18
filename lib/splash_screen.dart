import 'dashboard_screen.dart';
import 'services/auth_services.dart';
import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'dart:async';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  final AuthService user = AuthService();
  double _opacity = 0.0;
  double _scale = 0.8;
  double _offsetY = 20.0; // Initial downward position

  @override
  void initState() {
    super.initState();

    // Start the initial animation
    Future.delayed(Duration(milliseconds: 500), () {
      if (mounted) {
        setState(() {
          _opacity = 1.0;
          _scale = 1.0;
          _offsetY = 0.0; // Move text upwards slightly
        });
      }
    });

    // Move text upwards after 2 seconds
    Future.delayed(Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _offsetY = -150; // Move the text up
        });
      }
    });

    // Navigate to HomeScreen with animation after splash duration
    checkUserAuth();
  }

  Future<void> checkUserAuth() async {
    try {
      await Future.delayed(Duration(seconds: 3));

      if (!mounted) return;

      print("Checking user authentication...");
      bool isAuthenticated = await AuthService().getUser(context);
      print("Authentication check result: $isAuthenticated");

      if (!mounted) return;

      if (isAuthenticated) {
        print("User is authenticated, navigating to Dashboard");
        Navigator.pushReplacement(
          context,
          _createRoute(DashboardScreen()),
        );
      } else {
        print("User is not authenticated, navigating to Home");
        Navigator.pushReplacement(
          context,
          _createRoute(HomeScreen()),
        );
      }
    } catch (e) {
      print("Error in checkUserAuth: $e");
      if (mounted) {
        Navigator.pushReplacement(
          context,
          _createRoute(HomeScreen()),
        );
      }
    }
  }

  // Custom transition for smooth animation
  PageRouteBuilder _createRoute(Widget screen) {
    return PageRouteBuilder(
      transitionDuration: Duration(milliseconds: 800),
      pageBuilder: (context, animation, secondaryAnimation) => screen,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        var fadeTween = Tween<double>(begin: 0.2, end: 1.0);
        var scaleTween = Tween<double>(begin: 0.9, end: 1.0);

        return FadeTransition(
          opacity: animation.drive(fadeTween),
          child: ScaleTransition(
            scale: animation.drive(scaleTween),
            child: child,
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF6C9D7A),
      body: Center(
        child: AnimatedOpacity(
          duration: Duration(seconds: 4), // Extended to 4 seconds
          opacity: _opacity,
          child: TweenAnimationBuilder(
            duration: Duration(seconds: 4), // Extended to 4 seconds
            tween: Tween<double>(begin: _scale, end: 1.0),
            curve: Curves.easeOut,
            builder: (context, double scale, child) {
              return Transform.scale(
                scale: scale,
                child: child,
              );
            },
            child: AnimatedContainer(
              duration: Duration(seconds: 4), // Extended to 4 seconds
              curve: Curves.easeInOut,
              transform: Matrix4.translationValues(0, _offsetY, 0),
              child: Text(
                'Eco Pulse',
                style: TextStyle(
                  fontSize: 80,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'MonteCarlo',
                  color: Color(0xff67460E),
                  letterSpacing: 2.0,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
