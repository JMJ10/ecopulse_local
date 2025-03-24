import 'package:flutter/material.dart';
import 'package:ecopulse_local/waste_management/waste_management_screen.dart';
import 'chat/chat_screen.dart';
import 'package:ecopulse_local/carbon_emission/carbon_emission_screen.dart';
import 'sustainable_transportation_screen.dart';
import 'profile_screen.dart';
import 'package:ecopulse_local/services/auth_services.dart';
import 'ecolearn_screen.dart';
import 'sustainability_insights_screen.dart';

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
    {
    'title': 'EcoLearn',
    'icon': Icons.school,
    'color': Colors.green.shade700,
    'screen': EcoLearnScreen(),
    },
    {
      'title': 'Sustainability Insights',
      'icon': Icons.insights,
      'color': Colors.purple,
      'screen': SustainabilityInsightsScreen(),
    },

  ];

  DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
    onWillPop: () async {
      // You can show a dialog here asking if the user wants to exit the app
      // Return true to allow back button (exit app), false to prevent it
      return await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Exit App', 
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        content: Text('Are you sure you want to exit the app?'),
        backgroundColor: Colors.green[50], // Light green background
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: Colors.green, width: 2),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            style: TextButton.styleFrom(
              backgroundColor: Colors.green, // Red for "No"
              foregroundColor: Colors.white,
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text('No', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green, // Green button
              foregroundColor: Colors.white,
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text('Yes', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    ) ?? false;
  },
      child: Scaffold(
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
        tooltip: 'Chat with EcoPulse AI',
        child: Icon(
          Icons.chat_bubble_outline,
          color: Colors.white,
        ),
      ),
    )
    );
  }
}
