import 'package:flutter/material.dart';
import 'login_screen.dart'; // Import LoginScreen
import 'register_screen.dart'; // Import RegisterScreen

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  double _opacity = 0.0;
  double _scale = 0.9;
  double _offsetY = 30.0; // Start slightly below for smooth entrance

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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(kToolbarHeight),
        child: SafeArea(
          child: AppBar(
            backgroundColor: Color(0xFF6C9D7A),
            elevation: 0,
          ),
        ),
      ),
      backgroundColor: Color(0xFF6C9D7A),
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
                mainAxisSize: MainAxisSize.min,
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
                  const Text(
                    'Eco Pulse',
                    style: TextStyle(
                      fontSize: 80,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'MonteCarlo',
                      color: Color(0xff67460E),
                    ),
                  ),
                  const SizedBox(height: 110),
                  const Text(
                    'Empowering You to Live Green, One Step at a Time.',
                    style: TextStyle(
                        fontSize: 18,
                        color: Color.fromARGB(255, 255, 255, 255)),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 60),
                  SizedBox(
                    width: 200,
                    child: ElevatedButton(
                      onPressed: () {
                        _navigateWithAnimation(context, LoginScreen());
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF2D5C5A),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                          side: BorderSide(
                            color: Color(0xFF2D5C5A),
                            width: 2,
                          ),
                        ),
                      ),
                      child: const Text('Login'),
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: 200,
                    child: ElevatedButton(
                      onPressed: () {
                        _navigateWithAnimation(context, RegisterScreen());
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF6C9D7A),
                        foregroundColor: Color(0xFF1F3B3D),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                          side: BorderSide(
                            color: Color(0xFF1F3B3D),
                            width: 1,
                          ),
                        ),
                      ),
                      child: const Text('Sign Up'),
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

  // 🔥 Custom Transition Function
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
