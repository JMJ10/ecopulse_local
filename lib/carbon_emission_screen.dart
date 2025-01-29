import 'package:flutter/material.dart';

class CarbonEmissionScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Carbon Emission Features')),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            FeatureContainer(
              title: 'Carbon Footprint Calculator',
              onTap: () {
                // Navigate to Carbon Footprint Calculator Screen
              },
            ),
            FeatureContainer(
              title: 'Daily/Weekly Emission Tracker',
              onTap: () {
                // Navigate to Emission Tracker Screen
              },
            ),
            FeatureContainer(
              title: 'Sustainable Challenges & Rewards',
              onTap: () {
                // Navigate to Challenges & Rewards Screen
              },
            ),
          ],
        ),
      ),
    );
  }
}

// Reusable Container Widget
class FeatureContainer extends StatelessWidget {
  final String title;
  final VoidCallback onTap;

  FeatureContainer({required this.title, required this.onTap});

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
        child: Center(
          child: Text(
            title,
            style: TextStyle(color: Colors.white, fontSize: 18),
          ),
        ),
      ),
    );
  }
}
