import 'package:flutter/material.dart';

class DashboardScreen extends StatelessWidget {
  // List of eco-friendly options
  final List<String> ecoOptions = [
    'Waste Management',
    'Carbon Emission',
    'Energy Consumption',
    'Sustainable Transportation', // New category added
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Eco Practices Dashboard'),
        backgroundColor: Colors.green, // Consistent color scheme
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0), // Padding around the list
        child: ListView.builder(
          itemCount: ecoOptions.length,
          itemBuilder: (context, index) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12.0), // Space between cards
              child: Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0), // Rounded corners
                ),
                elevation: 4.0, // Shadow effect for a raised look
                child: InkWell(
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('${ecoOptions[index]} selected'),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  },
                  splashColor: Colors.green.withOpacity(0.2), // Ripple effect
                  child: Container(
                    height: 120, // Larger height for better visuals
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        CircleAvatar( // Icon or image
                          backgroundColor: Colors.green,
                          child: Icon(Icons.eco, color: Colors.white),
                          radius: 30,
                        ),
                        SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                ecoOptions[index],
                                style: TextStyle(
                                  fontSize: 20.0,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 8),
                              Text(
                                'Learn more about ${ecoOptions[index].toLowerCase()} practices.',
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
              ),
            );
          },
        ),
      ),
    );
  }
}
