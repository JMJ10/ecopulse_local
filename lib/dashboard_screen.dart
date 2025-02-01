import 'package:flutter/material.dart';
import 'waste_management_screen.dart';
import 'carbon_emission_screen.dart';
import 'sustainable_transportation_screen.dart'; // Import the new screen

class DashboardScreen extends StatelessWidget {
  // List of eco-friendly options
  final List<String> ecoOptions = [
    'Waste Management',
    'Carbon Emission',
    'Sustainable Transportation',
  ];

  DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Eco Practices Dashboard'),
        backgroundColor: Colors.green,
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: ListView.builder(
          itemCount: ecoOptions.length,
          itemBuilder: (context, index) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12.0),
              child: Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
                elevation: 4.0,
                child: InkWell(
                  onTap: () {
                    if (ecoOptions[index] == 'Waste Management') {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => WasteManagementScreen(),
                        ),
                      );
                    } else if (ecoOptions[index] == 'Carbon Emission') {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => CarbonEmissionScreen(),
                        ),
                      );
                    } else if (ecoOptions[index] == 'Sustainable Transportation') {
                      // Navigate to Sustainable Transportation Screen
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => SustainableTransportationScreen(),
                        ),
                      );
                    }
                  },
                  splashColor: Colors.green.withOpacity(0.3),
                  child: Container(
                    height: 120,
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: Colors.green,
                          radius: 30,
                          child: Icon(Icons.directions_car, color: Colors.white),
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
