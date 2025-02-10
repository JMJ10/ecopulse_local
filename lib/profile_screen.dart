import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ecopulse_local/providers/user_provider.dart';

class ProfileScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserProvider>(context).user;

    return Scaffold(
      appBar: AppBar(
        title: Text('Profile'),
        backgroundColor: Colors.green,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Align(
          alignment: Alignment.center,
          child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 50,
              backgroundColor: Colors.green,
              child: Icon(Icons.person, size: 50, color: Colors.white),
            ),
            SizedBox(height: 16),
            Text(
              user.name, // Fetching name from user provider
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              user.email,
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            SizedBox(height: 8),
            Text(
              "Location: ${user.location}",
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Implement Logout Functionality
              },
              child: Text('Logout'),
            ),
          ],
        ),
        ),
        ),
      );
  }
}
