// lib/screens/sustainability_insights_screen.dart
import 'package:flutter/material.dart';
import 'package:ecopulse_local/models/recommendation.dart';
import 'package:ecopulse_local/services/recommendation_service.dart';
import 'package:ecopulse_local/widgets/recommendation_card.dart';

class SustainabilityInsightsScreen extends StatefulWidget {
  const SustainabilityInsightsScreen({Key? key}) : super(key: key);

  @override
  _SustainabilityInsightsScreenState createState() => _SustainabilityInsightsScreenState();
}

class _SustainabilityInsightsScreenState extends State<SustainabilityInsightsScreen> {
  final RecommendationService _recommendationService = RecommendationService();
  bool _isLoading = true;
  RecommendationsResponse? _recommendations;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadRecommendations();
  }

  Future<void> _loadRecommendations() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final recommendations = await _recommendationService.getRecommendations(context);
      
      if (mounted) {
        setState(() {
          _recommendations = recommendations;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sustainability Insights'),
        backgroundColor: Colors.green,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadRecommendations,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.green))
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline, color: Colors.red, size: 48),
                      const SizedBox(height: 16),
                      Text(
                        'Error loading recommendations',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 8),
                      Text(_error!, style: const TextStyle(color: Colors.red)),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: _loadRecommendations,
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                        child: const Text('Try Again'),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadRecommendations,
                  color: Colors.green,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Summary Section
                        _buildSummaryCard(),
                        const SizedBox(height: 24),

                        // Waste Recommendations
                        _buildSectionHeader(
                          'Waste Management Insights',
                          Icons.delete_outline,
                          Colors.orange,
                        ),
                        const SizedBox(height: 8),
                        ..._recommendations!.wasteRecommendations.map((rec) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12.0),
                            child: RecommendationCard(recommendation: rec),
                          );
                        }).toList(),
                        const SizedBox(height: 16),

                        // Carbon Recommendations
                        _buildSectionHeader(
                          'Carbon Emission Insights',
                          Icons.cloud_outlined,
                          Colors.blue,
                        ),
                        const SizedBox(height: 8),
                        ..._recommendations!.carbonRecommendations.map((rec) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12.0),
                            child: RecommendationCard(recommendation: rec),
                          );
                        }).toList(),
                        const SizedBox(height: 16),

                        // General Tips
                        _buildSectionHeader(
                          'Sustainability Tips',
                          Icons.eco_outlined,
                          Colors.green,
                        ),
                        const SizedBox(height: 8),
                        ..._recommendations!.generalTips.map((rec) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12.0),
                            child: RecommendationCard(recommendation: rec),
                          );
                        }).toList(),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon, Color color) {
    return Row(
      children: [
        Icon(icon, color: color),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryCard() {
    // Count total recommendations and insights
    final totalInsights = _recommendations!.wasteRecommendations.length +
        _recommendations!.carbonRecommendations.length +
        _recommendations!.generalTips.length;

    // Count warnings
    final warningsCount = _recommendations!.wasteRecommendations
            .where((rec) => rec.type == 'warning')
            .length +
        _recommendations!.carbonRecommendations
            .where((rec) => rec.type == 'warning')
            .length;

    // Count positive feedback
    final positiveCount = _recommendations!.wasteRecommendations
            .where((rec) => rec.type == 'success')
            .length +
        _recommendations!.carbonRecommendations
            .where((rec) => rec.type == 'success')
            .length;

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      color: Colors.green.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Your Sustainability Summary",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildSummaryItem(
                  totalInsights.toString(),
                  "Total Insights",
                  Icons.insights,
                  Colors.deepPurple,
                ),
                _buildSummaryItem(
                  warningsCount.toString(),
                  "Areas to Improve",
                  Icons.warning_amber,
                  Colors.orange,
                ),
                _buildSummaryItem(
                  positiveCount.toString(),
                  "Achievements",
                  Icons.emoji_events,
                  Colors.amber,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryItem(
      String value, String label, IconData icon, Color color) {
    return Column(
      children: [
        CircleAvatar(
          radius: 24,
          backgroundColor: color.withOpacity(0.2),
          child: Icon(icon, color: color),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade700,
          ),
        ),
      ],
    );
  }
}