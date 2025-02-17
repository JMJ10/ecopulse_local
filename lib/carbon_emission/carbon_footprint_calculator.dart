import 'package:flutter/material.dart';

class CarbonFootprintCalculator extends StatefulWidget {
  const CarbonFootprintCalculator({Key? key}) : super(key: key);

  @override
  CarbonFootprintCalculatorState createState() => CarbonFootprintCalculatorState();
}

class CarbonFootprintCalculatorState extends State<CarbonFootprintCalculator> {
  String _selectedMode = 'Car';
  double _distance = 0.0;
  double _result = 0.0;

  final Map<String, Map<String, dynamic>> _modeFactors = {
    'Car': {
      'factor': 0.2,
      'icon': Icons.directions_car,
      'color': Colors.blue
    },
    'Bus': {
      'factor': 0.1,
      'icon': Icons.directions_bus,
      'color': Colors.orange
    },
    'Train': {
      'factor': 0.05,
      'icon': Icons.train,
      'color': Colors.red
    },
    'Bike': {
      'factor': 0.0,
      'icon': Icons.pedal_bike,
      'color': Colors.green
    },
  };

  void _calculateFootprint() {
    setState(() {
      _result = _distance * (_modeFactors[_selectedMode]?['factor'] ?? 0.0);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Carbon Footprint Calculator'),
        backgroundColor: Colors.green,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      const Text(
                        'Enter Travel Details',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 20),
                      TextField(
                        decoration: InputDecoration(
                          labelText: 'Distance (miles)',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          prefixIcon: const Icon(Icons.straighten),
                        ),
                        keyboardType: TextInputType.number,
                        onChanged: (value) {
                          setState(() {
                            _distance = double.tryParse(value) ?? 0.0;
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Select Mode of Transport',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      ..._modeFactors.keys.map((String mode) {
                        return RadioListTile<String>(
                          title: Row(
                            children: [
                              Icon(
                                _modeFactors[mode]!['icon'],
                                color: _modeFactors[mode]!['color'],
                              ),
                              const SizedBox(width: 10),
                              Text(mode),
                            ],
                          ),
                          value: mode,
                          groupValue: _selectedMode,
                          onChanged: (String? value) {
                            setState(() {
                              _selectedMode = value!;
                            });
                          },
                        );
                      }).toList(),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _calculateFootprint,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  'Calculate Footprint',
                  style: TextStyle(fontSize: 18),
                ),
              ),
              const SizedBox(height: 20),
              if (_result > 0)
                Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        const Text(
                          'Your Carbon Footprint',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          '${_result.toStringAsFixed(2)} kg CO₂',
                          style: const TextStyle(
                            fontSize: 24,
                            color: Colors.green,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'Mode: $_selectedMode',
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}