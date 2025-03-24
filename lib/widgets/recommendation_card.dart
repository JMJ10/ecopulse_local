// lib/widgets/recommendation_card.dart
import 'package:flutter/material.dart';
import 'package:ecopulse_local/models/recommendation.dart';

class RecommendationCard extends StatelessWidget {
  final SustainabilityRecommendation recommendation;
  
  const RecommendationCard({
    Key? key,
    required this.recommendation,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: _getBorderColor(),
          width: 1.5,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  _getIconData(),
                  color: _getIconColor(),
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    recommendation.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              recommendation.description,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getIconData() {
    switch (recommendation.type) {
      case 'warning':
        return Icons.warning_amber_rounded;
      case 'success':
        return Icons.check_circle_outline;
      case 'suggestion':
        return Icons.lightbulb_outline;
      case 'tip':
        return Icons.tips_and_updates_outlined;
      case 'info':
      default:
        return Icons.info_outline;
    }
  }

  Color _getIconColor() {
    switch (recommendation.type) {
      case 'warning':
        return Colors.orange;
      case 'success':
        return Colors.green;
      case 'suggestion':
        return Colors.blue;
      case 'tip':
        return Colors.purple;
      case 'info':
      default:
        return Colors.teal;
    }
  }

  Color _getBorderColor() {
    switch (recommendation.type) {
      case 'warning':
        return Colors.orange.shade200;
      case 'success':
        return Colors.green.shade200;
      case 'suggestion':
        return Colors.blue.shade200;
      case 'tip':
        return Colors.purple.shade200;
      case 'info':
      default:
        return Colors.teal.shade200;
    }
  }
}