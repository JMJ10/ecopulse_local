// lib/models/recommendation.dart

class SustainabilityRecommendation {
  final String type; // 'info', 'warning', 'success', 'suggestion', 'tip'
  final String title;
  final String description;

  SustainabilityRecommendation({
    required this.type,
    required this.title,
    required this.description,
  });

  factory SustainabilityRecommendation.fromJson(Map<String, dynamic> json) {
    return SustainabilityRecommendation(
      type: json['type'] ?? 'info',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
    );
  }
}

class RecommendationsResponse {
  final List<SustainabilityRecommendation> wasteRecommendations;
  final List<SustainabilityRecommendation> carbonRecommendations;
  final List<SustainabilityRecommendation> generalTips;

  RecommendationsResponse({
    required this.wasteRecommendations,
    required this.carbonRecommendations,
    required this.generalTips,
  });

  factory RecommendationsResponse.fromJson(Map<String, dynamic> json) {
    // Parse waste recommendations
    final wasteRecommendations = (json['wasteRecommendations'] as List?)
            ?.map((item) => SustainabilityRecommendation.fromJson(item))
            .toList() ??
        [];

    // Parse carbon recommendations
    final carbonRecommendations = (json['carbonRecommendations'] as List?)
            ?.map((item) => SustainabilityRecommendation.fromJson(item))
            .toList() ??
        [];

    // Parse general tips
    final generalTips = (json['generalTips'] as List?)
            ?.map((item) => SustainabilityRecommendation.fromJson(item))
            .toList() ??
        [];

    return RecommendationsResponse(
      wasteRecommendations: wasteRecommendations,
      carbonRecommendations: carbonRecommendations,
      generalTips: generalTips,
    );
  }
}