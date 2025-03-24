// lib/widgets/mini_recommendations_widget.dart
import 'package:flutter/material.dart';
import 'package:ecopulse_local/models/recommendation.dart';
import 'package:ecopulse_local/services/recommendation_service.dart';
import 'package:ecopulse_local/sustainability_insights_screen.dart';

class MiniRecommendationsWidget extends StatefulWidget {
  final String source; // 'waste' or 'carbon'
  
  const MiniRecommendationsWidget({
    Key? key,
    required this.source,
  }) : super(key: key);

  @override
  _MiniRecommendationsWidgetState createState() => _MiniRecommendationsWidgetState();
}

class _MiniRecommendationsWidgetState extends State<MiniRecommendationsWidget> {
  final RecommendationService _recommendationService = RecommendationService();
  bool _isLoading = true;
  String? _error;
  List<SustainabilityRecommendation> _recommendations = [];

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
      
      final recommendationsResponse = await _recommendationService.getRecommendations(context);
      
      if (mounted) {
        setState(() {
          if (widget.source == 'waste') {
            _recommendations = recommendationsResponse.wasteRecommendations;
          } else if (widget.source == 'carbon') {
            _recommendations = recommendationsResponse.carbonRecommendations;
          }
          
          // Limit to top 2 recommendations
          if (_recommendations.length > 2) {
            _recommendations = _recommendations.sublist(0, 2);
          }
          
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
    if (_isLoading) {
      return const SizedBox(
        height: 100,
        child: Center(
          child: CircularProgressIndicator(color: Colors.green),
        ),
      );
    }

    if (_error != null) {
      // Return a compact error widget
      return Card(
        margin: const EdgeInsets.all(16.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: Colors.red.shade200),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Icon(Icons.error_outline, color: Colors.red[700]),
                  const SizedBox(width: 8),
                  const Text(
                    'Could not load recommendations',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: _loadRecommendations,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(120, 36),
                ),
                child: const Text('Try Again'),
              ),
            ],
          ),
        ),
      );
    }

    if (_recommendations.isEmpty) {
      return const SizedBox.shrink(); // Hide if no recommendations
    }

    return Card(
      margin: const EdgeInsets.all(16.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.green.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  widget.source == 'waste' ? 'Waste Tips' : 'Carbon Emission Tips',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const SustainabilityInsightsScreen(),
                      ),
                    );
                  },
                  child: const Text('See All'),
                ),
              ],
            ),
            const Divider(),
            ..._recommendations.map((rec) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _getIconForRecommendationType(rec.type),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            rec.title,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            rec.description,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[700],
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
            const SizedBox(height: 8),
            Center(
              child: TextButton.icon(
                onPressed: _loadRecommendations,
                icon: const Icon(Icons.refresh, size: 16),
                label: const Text('Refresh'),
                style: TextButton.styleFrom(
                  foregroundColor: Colors.green,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _getIconForRecommendationType(String type) {
    switch (type) {
      case 'warning':
        return Icon(Icons.warning_amber_rounded, color: Colors.orange[700], size: 20);
      case 'success':
        return Icon(Icons.check_circle, color: Colors.green[700], size: 20);
      case 'suggestion':
        return Icon(Icons.lightbulb_outline, color: Colors.blue[700], size: 20);
      case 'tip':
        return Icon(Icons.tips_and_updates, color: Colors.purple[700], size: 20);
      case 'info':
      default:
        return Icon(Icons.info_outline, color: Colors.cyan[700], size: 20);
    }
  }
}