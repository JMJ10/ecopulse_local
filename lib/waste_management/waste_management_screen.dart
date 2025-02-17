import 'package:flutter/material.dart';
import 'package:ecopulse_local/waste_management/log_waste_screen.dart';
import 'package:ecopulse_local/waste_management/recycle_centers_screen.dart';
import 'package:ecopulse_local/waste_management/collect_dates_screen.dart';
import 'package:ecopulse_local/waste_management/waste_service.dart';
import 'package:ecopulse_local/models/wastelog.dart';
import 'package:fl_chart/fl_chart.dart';

class WasteManagementScreen extends StatefulWidget {
  const WasteManagementScreen({Key? key}) : super(key: key);

  @override
  _WasteManagementScreenState createState() => _WasteManagementScreenState();
}

class _WasteManagementScreenState extends State<WasteManagementScreen> {
  final WasteService _wasteService = WasteService();
  bool isLoading = true;
  List<WasteLog> wasteLogs = [];
  Map<String, double> wasteByType = {};

  @override
  void initState() {
    super.initState();
    _loadWasteLogs();
  }

  Future<void> _loadWasteLogs() async {
    try {
      final logs = await _wasteService.getWasteLogs(context);
      
      // Calculate waste by type
      Map<String, double> typeMap = {};
      for (var log in logs) {
        if (typeMap.containsKey(log.wasteType)) {
          typeMap[log.wasteType] = typeMap[log.wasteType]! + log.quantity;
        } else {
          typeMap[log.wasteType] = log.quantity;
        }
      }
      
      setState(() {
        wasteLogs = logs;
        wasteByType = typeMap;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading waste logs: $e')),
      );
    }
  }

  Widget _buildWasteChart() {
    if (wasteByType.isEmpty) {
      return const Center(
        child: Text('No waste data available yet. Start logging your waste!'),
      );
    }

    double maxValue = wasteByType.values.isNotEmpty ? wasteByType.values.reduce((a, b) => a > b ? a : b) : 1;

    return Container(
      height: 250,
      padding: const EdgeInsets.all(16),
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: maxValue + 5,
          barGroups: wasteByType.entries.map((entry) {
            return BarChartGroupData(
              x: wasteByType.keys.toList().indexOf(entry.key),
              barRods: [
                BarChartRodData(
                  toY: entry.value,
                  color: _getColorForWasteType(entry.key),
                  width: 20,
                  borderRadius: BorderRadius.circular(4),
                ),
              ],
            );
          }).toList(),
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                interval: maxValue / 5,
                reservedSize: 40,
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (double value, TitleMeta meta) {
                  if (value.toInt() >= 0 && value.toInt() < wasteByType.keys.length) {
                    return Text(wasteByType.keys.elementAt(value.toInt()), style: TextStyle(fontSize: 12));
                  }
                  return const Text('');
                },
                reservedSize: 32,
              ),
            ),
          ),
          borderData: FlBorderData(show: false),
          gridData: FlGridData(show: true),
        ),
      ),
    );
  }

  Color _getColorForWasteType(String type) {
    switch (type.toLowerCase()) {
      case 'plastic':
        return Colors.blue;
      case 'paper':
        return Colors.brown;
      case 'glass':
        return Colors.teal;
      case 'metal':
        return Colors.grey;
      case 'organic':
        return Colors.green;
      case 'electronic':
        return Colors.orange;
      default:
        return Colors.purple;
    }
  }

  Widget _buildFeatureCard(
      {required String title,
      required IconData icon,
      required VoidCallback onTap,
      required String description}) {
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
        title: const Text('Waste Management'),
        backgroundColor: Colors.green,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadWasteLogs,
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
                      child: _buildWasteChart(),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Waste Management Actions',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildFeatureCard(
                      title: 'Log Waste',
                      icon: Icons.add_circle_outline,
                      description: 'Record the waste you\'ve generated or recycled',
                      onTap: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const LogWasteScreen()),
                        );
                        _loadWasteLogs(); // Refresh after returning
                      },
                    ),
                    const SizedBox(height: 12),
                    _buildFeatureCard(
                      title: 'Recycling Centers',
                      icon: Icons.location_on_outlined,
                      description: 'Find recycling centers near your location',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const RecyclingCentersScreen()),
                        );
                      },
                    ),
                    const SizedBox(height: 12),
                    _buildFeatureCard(
                      title: 'Collection Dates',
                      icon: Icons.calendar_today_outlined,
                      description: 'View upcoming waste collection schedules',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const CollectionDatesScreen()),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}