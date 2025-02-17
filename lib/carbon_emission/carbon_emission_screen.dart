import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:ecopulse_local/carbon_emission/carbon_footprint_calculator.dart';

class CarbonEmissionScreen extends StatefulWidget {
  const CarbonEmissionScreen({Key? key}) : super(key: key);

  @override
  _CarbonEmissionScreenState createState() => _CarbonEmissionScreenState();
}

class _CarbonEmissionScreenState extends State<CarbonEmissionScreen> {
  bool isLoading = false;
  // Sample data - in a real app, this would come from your backend
  final Map<String, double> emissionsByMode = {
    'Car': 125.5,
    'Bus': 45.2,
    'Train': 25.8,
    'Bike': 0.0,
  };

  Widget _buildEmissionsChart() {
  if (emissionsByMode.isEmpty) {
    return const Center(
      child: Text('No emission data available yet. Start tracking your carbon footprint!'),
    );
  }

  double maxValue = emissionsByMode.values.reduce((a, b) => a > b ? a : b);
  // Round up to nearest 50 for better scale
  maxValue = ((maxValue + 49) ~/ 50) * 50.0;
  
  return Container(
    height: 350, // Increased height
    padding: const EdgeInsets.fromLTRB(16, 24, 24, 16), // Adjusted padding
    child: BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: maxValue,
        minY: 0,
        barGroups: emissionsByMode.entries.map((entry) {
          return BarChartGroupData(
            x: emissionsByMode.keys.toList().indexOf(entry.key),
            barRods: [
              BarChartRodData(
                toY: entry.value,
                color: _getColorForTransportMode(entry.key),
                width: 25, // Slightly wider bars
                borderRadius: BorderRadius.circular(4),
              ),
            ],
          );
        }).toList(),
        titlesData: FlTitlesData(
          show: true,
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          leftTitles: AxisTitles(
            axisNameWidget: const Text(
              'CO₂ Emissions (kg)',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 50, // More space for labels
              interval: maxValue / 5, // 5 intervals on Y axis
              getTitlesWidget: (value, meta) {
                return Text(
                  value.toStringAsFixed(1),
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                );
              },
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40, // More space for labels
              getTitlesWidget: (double value, TitleMeta meta) {
                if (value.toInt() >= 0 && value.toInt() < emissionsByMode.keys.length) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: RotatedBox(
                      quarterTurns: 1, // Rotate text 90 degrees
                      child: Text(
                        emissionsByMode.keys.elementAt(value.toInt()),
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  );
                }
                return const Text('');
              },
            ),
          ),
        ),
        borderData: FlBorderData(
          show: true,
          border: Border(
            left: BorderSide(color: Colors.grey[300]!),
            bottom: BorderSide(color: Colors.grey[300]!),
          ),
        ),
        gridData: FlGridData(
          show: true,
          drawHorizontalLine: true,
          horizontalInterval: maxValue / 10, // More grid lines
          getDrawingHorizontalLine: (value) => FlLine(
            color: Colors.grey[200]!,
            strokeWidth: 1,
          ),
        ),
      ),
    ),
  );
}

  Color _getColorForTransportMode(String mode) {
    switch (mode.toLowerCase()) {
      case 'car':
        return Colors.red;
      case 'bus':
        return Colors.orange;
      case 'train':
        return Colors.blue;
      case 'bike':
        return Colors.green;
      default:
        return Colors.purple;
    }
  }

  Widget _buildFeatureCard({
    required String title,
    required IconData icon,
    required VoidCallback onTap,
    required String description,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  size: 30,
                  color: Colors.green,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios, size: 16),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Carbon Emission'),
        backgroundColor: Colors.green,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: () async {
                // Implement refresh logic here
              },
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 4,
                      child: _buildEmissionsChart(),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Carbon Management Actions',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildFeatureCard(
                      title: 'Carbon Footprint Calculator',
                      icon: Icons.calculate_outlined,
                      description: 'Calculate your travel carbon footprint',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const CarbonFootprintCalculator(),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 12),
                    _buildFeatureCard(
                      title: 'Daily Emission Tracker',
                      icon: Icons.track_changes,
                      description: 'Log and monitor your daily carbon emissions',
                      onTap: () {
                        // Navigate to Daily Emission Tracker
                      },
                    ),
                    const SizedBox(height: 12),
                    _buildFeatureCard(
                      title: 'Sustainable Challenges',
                      icon: Icons.emoji_events_outlined,
                      description: 'Complete challenges to reduce your carbon footprint',
                      onTap: () {
                        // Navigate to Challenges Screen
                      },
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}