import 'package:flutter/material.dart';
import 'package:ecopulse_local/waste_management/waste_management_screen.dart';
import 'chat/chat_screen.dart';
import 'package:ecopulse_local/carbon_emission/carbon_emission_screen.dart';
import 'sustainable_transportation_screen.dart';
import 'profile_screen.dart';
import 'package:ecopulse_local/services/auth_services.dart';

class DashboardScreen extends StatelessWidget {
  final AuthService _authService = AuthService();

  final List<Map<String, dynamic>> ecoOptions = [
    {
      'title': 'Waste Management',
      'icon': Icons.delete_outline,
      'color': Colors.orange,
      'screen': WasteManagementScreen(),
    },
    {
      'title': 'Carbon Emission',
      'icon': Icons.cloud,
      'color': Colors.blue,
      'screen': CarbonEmissionScreen(),
    },
    {
      'title': 'Sustainable Transportation',
      'icon': Icons.directions_bus,
      'color': Colors.green,
      'screen': SustainableTransportationScreen(),
    },
  ];

  DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Eco Practices'),
        backgroundColor: Colors.green,
        automaticallyImplyLeading: false,
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'Profile') {
                Navigator.push(
                  context,
                  PageRouteBuilder(
                    transitionDuration: Duration(milliseconds: 600),
                    pageBuilder: (context, animation, secondaryAnimation) =>
                        ProfileScreen(),
                    transitionsBuilder:
                        (context, animation, secondaryAnimation, child) {
                      return SlideTransition(
                        position: Tween<Offset>(
                          begin: Offset(1, 0),
                          end: Offset(0, 0),
                        ).animate(CurvedAnimation(
                          parent: animation,
                          curve: Curves.easeInOut,
                        )),
                        child: child,
                      );
                    },
                  ),
                );
              } else if (value == 'Logout') {
                _authService.logout(context);
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'Profile',
                child: ListTile(
                  leading: Icon(Icons.person),
                  title: Text('Profile'),
                ),
              ),
              PopupMenuItem(
                value: 'Logout',
                child: ListTile(
                  leading: Icon(Icons.logout, color: Colors.red),
                  title: Text('Logout', style: TextStyle(color: Colors.red)),
                ),
              ),
            ],
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView.builder(
          itemCount: ecoOptions.length,
          itemBuilder: (context, index) {
            return Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16.0),
              ),
              elevation: 6.0,
              child: InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    PageRouteBuilder(
                      transitionDuration: Duration(milliseconds: 600),
                      pageBuilder: (context, animation, secondaryAnimation) =>
                          ecoOptions[index]['screen'],
                      transitionsBuilder:
                          (context, animation, secondaryAnimation, child) {
                        return SlideTransition(
                          position: Tween<Offset>(
                            begin: Offset(1, 0),
                            end: Offset(0, 0),
                          ).animate(CurvedAnimation(
                            parent: animation,
                            curve: Curves.easeInOut,
                          )),
                          child: child,
                        );
                      },
                    ),
                  );
                },
                splashColor: ecoOptions[index]['color'].withOpacity(0.3),
                child: Container(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: ecoOptions[index]['color'],
                        radius: 35,
                        child: Icon(
                          ecoOptions[index]['icon'],
                          color: Colors.white,
                          size: 30,
                        ),
                      ),
                      SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              ecoOptions[index]['title'],
                              style: TextStyle(
                                fontSize: 18.0,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 6),
                            Text(
                              'Explore ${ecoOptions[index]['title'].toLowerCase()} practices.',
                              style: TextStyle(color: Colors.grey[600]),
                            ),
                          ],
                        ),
                      ),
                      Icon(Icons.arrow_forward_ios, color: Colors.grey),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            PageRouteBuilder(
              transitionDuration: Duration(milliseconds: 600),
              pageBuilder: (context, animation, secondaryAnimation) =>
                  ChatScreen(),
              transitionsBuilder:
                  (context, animation, secondaryAnimation, child) {
                return SlideTransition(
                  position: Tween<Offset>(
                    begin: Offset(1, 0),
                    end: Offset(0, 0),
                  ).animate(CurvedAnimation(
                    parent: animation,
                    curve: Curves.easeInOut,
                  )),
                  child: child,
                );
              },
            ),
          );
        },
        backgroundColor: Colors.green,
        child: Icon(
          Icons.chat_bubble_outline,
          color: Colors.white,
        ),
        tooltip: 'Chat with EcoPulse AI',
      ),
    );
  }
}
