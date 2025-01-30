import 'package:flutter/material.dart';

class WasteManagementScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Waste Management')),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            FeatureContainer(title: "Waste Reduction Tips"),
            FeatureContainer(title: "Community Challenges"),
            FeatureContainer(title: "Waste Tracking"),
            FeatureContainer(title: "Rewards & Achievements"),
          ],
        ),
      ),
    );
  }
}

class FeatureContainer extends StatelessWidget {
  final String title;

  FeatureContainer({required this.title});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 10),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.green[100],
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          Icon(Icons.arrow_forward, color: Colors.green),
        ],
      ),
    );
  }
}