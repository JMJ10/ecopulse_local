//ecolearn_model
class EcoLearnArticle {
  final String id;
  final String title;
  final String summary;
  final String content;
  final String? imageUrl;
  final String? sourceUrl;
  final String dateCreated;

  EcoLearnArticle({
    required this.id,
    required this.title,
    required this.summary,
    required this.content,
    this.imageUrl,
    this.sourceUrl,
    required this.dateCreated,
  });

  factory EcoLearnArticle.fromJson(Map<String, dynamic> json) {
    return EcoLearnArticle(
      id: json['_id'],
      title: json['title'],
      summary: json['summary'],
      content: json['content'],
      imageUrl: json['imageUrl'],
      sourceUrl: json['sourceUrl'],
      dateCreated: json['dateCreated'],
    );
  }
}

class EcoLearnCategory {
  final String id;
  final String name;
  final String description;
  final String iconName;
  final List<EcoLearnArticle> articles;

  EcoLearnCategory({
    required this.id,
    required this.name,
    required this.description,
    required this.iconName,
    required this.articles,
  });

  factory EcoLearnCategory.fromJson(Map<String, dynamic> json) {
    return EcoLearnCategory(
      id: json['_id'],
      name: json['name'],
      description: json['description'],
      iconName: json['iconName'],
      articles: (json['articles'] as List)
          .map((article) => EcoLearnArticle.fromJson(article))
          .toList(),
    );
  }
}

class EcoLearnTip {
  final String id;
  final String title;
  final String content;
  final String? category;
  final int difficulty;

  EcoLearnTip({
    required this.id,
    required this.title,
    required this.content,
    this.category,
    required this.difficulty,
  });

  factory EcoLearnTip.fromJson(Map<String, dynamic> json) {
    return EcoLearnTip(
      id: json['_id'],
      title: json['title'],
      content: json['content'],
      category: json['category'],
      difficulty: json['difficulty'],
    );
  }
}