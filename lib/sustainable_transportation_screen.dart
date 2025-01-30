import 'package:flutter/material.dart';

class SustainableTransportationScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Sustainable Transportation')),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            FeatureContainer(
              title: 'Eco-Friendly Route Suggestions',
              icon: Icons.map,
              onTap: () {
                // Navigate to Eco-Friendly Route Suggestions Screen
              },
            ),
            FeatureContainer(
              title: 'Gamification and Challenges',
              icon: Icons.emoji_events,
              onTap: () {
                // Navigate to Gamification and Challenges Screen
              },
            ),
            FeatureContainer(
              title: 'EV Charging Station Finder',
              icon: Icons.electric_car,
              onTap: () {
                // Navigate to EV Charging Station Finder Screen
              },
            ),
          ],
        ),
      ),
    );
  }
}

// Reusable Container Widget for Features
class FeatureContainer extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback onTap;

  FeatureContainer({required this.title, required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 8),
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.blueAccent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.white, size: 30),
            SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: TextStyle(color: Colors.white, fontSize: 18),
              ),
            ),
            Icon(Icons.arrow_forward_ios, color: Colors.white),
          ],
        ),
      ),
    );
  }
}
