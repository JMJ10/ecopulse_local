import 'package:flutter/material.dart';
import 'package:ecopulse_local/login_screen.dart';
import 'package:ecopulse_local/register_screen.dart';
import 'package:ecopulse_local/admin_loginscreen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  double _opacity = 0.0;
  double _scale = 0.9;
  double _offsetY = 30.0; // Start slightly below for smooth entrance
  
  // Special animation values for admin button
  double _adminOpacity = 0.0;
  double _adminScale = 0.8;

  @override
  void initState() {
    super.initState();

    // Delayed fade-in and slide-up animation
    Future.delayed(Duration(milliseconds: 400), () {
      if (mounted) {
        setState(() {
          _opacity = 1.0;
          _scale = 1.0;
          _offsetY = 0.0;
        });
      }
    });
    
    // Even more delayed animation for admin button to make it pop
    Future.delayed(Duration(milliseconds: 1000), () {
      if (mounted) {
        setState(() {
          _adminOpacity = 1.0;
          _adminScale = 1.0;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF6C9D7A), // Exact match with splash screen
      body: Center(
        child: AnimatedOpacity(
          duration: Duration(seconds: 1),
          opacity: _opacity,
          child: TweenAnimationBuilder(
            duration: Duration(seconds: 1),
            tween: Tween<double>(begin: _scale, end: 1.0),
            curve: Curves.easeOut,
            builder: (context, double scale, child) {
              return Transform.scale(
                scale: scale,
                child: child,
              );
            },
            child: AnimatedContainer(
              duration: Duration(seconds: 1),
              curve: Curves.easeInOut,
              transform: Matrix4.translationValues(0, _offsetY, 0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
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
                  // Logo or app name with exact matching color from splash screen
                  const Text(
                    'Eco Pulse',
                    style: TextStyle(
                      fontSize: 70,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'MonteCarlo',
                      color: Color(0xff67460E),
                      letterSpacing: 2.0,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Empowering You to Live Green, One Step at a Time.',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 80),
                  
                  // Login button
                  SizedBox(
                    width: 250,
                    child: ElevatedButton(
                      onPressed: () {
                        _navigateWithAnimation(context, const LoginScreen());
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF2D5C5A),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        elevation: 4,
                      ),
                      child: const Text(
                        'Login',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Sign up button
                  SizedBox(
                    width: 250,
                    child: ElevatedButton(
                      onPressed: () {
                        _navigateWithAnimation(context, RegisterScreen());
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Color(0xFF2D5C5A),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                          side: BorderSide(
                            color: Color(0xFF2D5C5A),
                            width: 1,
                          ),
                        ),
                        elevation: 2,
                      ),
                      child: const Text(
                        'Sign Up',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 40),
                  
                  // Admin Login with special animation
                  AnimatedOpacity(
                    opacity: _adminOpacity,
                    duration: Duration(milliseconds: 800),
                    child: TweenAnimationBuilder(
                      duration: Duration(milliseconds: 800),
                      curve: Curves.elasticOut,
                      tween: Tween<double>(begin: _adminScale, end: 1.0),
                      builder: (context, double scale, child) {
                        return Transform.scale(
                          scale: scale,
                          child: child,
                        );
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black38,
                              blurRadius: 10,
                              offset: Offset(0, 4),
                            )
                          ],
                        ),
                        child: ElevatedButton.icon(
                          icon: Icon(Icons.admin_panel_settings, size: 20),
                          label: Text('Admin Login'),
                          onPressed: () {
                            _navigateWithAnimation(context, const AdminLoginScreen());
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFF1F3B3D),
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                            elevation: 6,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Custom Transition Function
  void _navigateWithAnimation(BuildContext context, Widget screen) {
    Navigator.push(
      context,
      PageRouteBuilder(
        transitionDuration: Duration(milliseconds: 600),
        pageBuilder: (context, animation, secondaryAnimation) => screen,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          var begin = Offset(0.0, 0.1); // Slide up slightly
          var end = Offset.zero;
          var curve = Curves.easeInOut;

          var tween =
              Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
          var fadeTween = Tween<double>(begin: 0.0, end: 1.0);

          return FadeTransition(
            opacity: animation.drive(fadeTween),
            child: SlideTransition(
              position: animation.drive(tween),
              child: child,
            ),
          );
        },
      ),
    );
  }
}