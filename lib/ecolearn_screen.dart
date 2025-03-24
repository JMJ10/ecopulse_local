import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'models/ecolearn.dart';
import '../utils/constants.dart';

class EcoLearnScreen extends StatefulWidget {
  const EcoLearnScreen({Key? key}) : super(key: key);

  @override
  _EcoLearnScreenState createState() => _EcoLearnScreenState();
}

class _EcoLearnScreenState extends State<EcoLearnScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool isLoading = true;
  String errorMessage = '';
  List<EcoLearnCategory> categories = [];
  List<EcoLearnTip> tips = [];

  @override
  void initState() {
    super.initState();
    _fetchEcoLearnData();
  }

  Future<void> _fetchEcoLearnData() async {
    try {
      // Get the auth token
      final token = await Constants.getToken();
      if (token == null || token.isEmpty) {
        _handleError('Authentication token is missing');
        return;
      }

      // Make the API request - note the corrected endpoint
      final response = await http.get(
  Uri.parse('${Constants.uri}/api/ecolearn'),
  headers: <String, String>{
    'Content-Type': 'application/json; charset=UTF-8',
    'x-auth-token': token,  
  },
).timeout(const Duration(seconds: 10)); // Add timeout

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        
        if (data.containsKey('categories') && data.containsKey('tips')) {
          setState(() {
            categories = (data['categories'] as List)
                .map((item) => EcoLearnCategory.fromJson(item))
                .toList();
            
            tips = (data['tips'] as List)
                .map((item) => EcoLearnTip.fromJson(item))
                .toList();
                
            _tabController = TabController(
              length: categories.length + 1, // +1 for Tips & Tricks tab
              vsync: this
            );
            
            isLoading = false;
          });
        } else {
          _handleError('Data format is incorrect');
        }
      } else {
        _handleError('Failed to load data: ${response.statusCode}');
        print('Response body: ${response.body}');
      }
    } catch (e) {
      _handleError('Network error: $e');
      print('Error details: $e');
    }
  }

  void _handleError(String message) {
    setState(() {
      isLoading = false;
      errorMessage = message;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Future<void> _retryFetch() async {
    setState(() {
      isLoading = true;
      errorMessage = '';
    });
    await _fetchEcoLearnData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('EcoLearn'),
        backgroundColor: Colors.green.shade700,
        bottom: isLoading || errorMessage.isNotEmpty
            ? null
            : TabBar(
                controller: _tabController,
                isScrollable: true,
                tabs: [
                  ...categories.map((category) => Tab(text: category.name)),
                  const Tab(text: 'Tips & Tricks'),
                ],
              ),
      ),
      body: isLoading 
          ? const Center(child: CircularProgressIndicator())
          : errorMessage.isNotEmpty
            ? _buildErrorView()
            : TabBarView(
                controller: _tabController,
                children: [
                  ...categories.map((category) => _buildCategoryTab(category)),
                  _buildTipsTab(),
                ],
              ),
    );
  }

  Widget _buildErrorView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.error_outline,
            color: Colors.red,
            size: 60,
          ),
          const SizedBox(height: 16),
          Text(
            'Unable to load content',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            errorMessage,
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey.shade700),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _retryFetch,
            icon: const Icon(Icons.refresh),
            label: const Text('Retry'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green.shade600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryTab(EcoLearnCategory category) {
    return category.articles.isEmpty
        ? _buildEmptyState('No articles found in this category')
        : ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: category.articles.length,
            itemBuilder: (context, index) {
              final article = category.articles[index];
              return _buildArticleCard(article);
            },
          );
  }

  Widget _buildArticleCard(EcoLearnArticle article) {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (article.imageUrl != null && article.imageUrl!.isNotEmpty)
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
              child: Image.network(
                article.imageUrl!,
                height: 180,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    height: 100,
                    color: Colors.grey.shade200,
                    child: const Center(
                      child: Icon(Icons.image_not_supported, color: Colors.grey),
                    ),
                  );
                },
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  article.title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(article.summary),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Created: ${article.dateCreated}',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        _showArticleDetails(article);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green.shade600,
                      ),
                      child: const Text('Read More'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTipsTab() {
    return tips.isEmpty
        ? _buildEmptyState('No tips available')
        : ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: tips.length,
            itemBuilder: (context, index) {
              final tip = tips[index];
              return _buildTipCard(tip);
            },
          );
  }

  Widget _buildTipCard(EcoLearnTip tip) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      color: Colors.green.shade50,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _buildDifficultyIndicator(tip.difficulty),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    tip.title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.only(left: 40),
              child: Text(tip.content),
            ),
            if (tip.category != null)
              Padding(
                padding: const EdgeInsets.only(left: 40, top: 8),
                child: Chip(
                  label: Text(
                    tip.category!,
                    style: const TextStyle(fontSize: 12),
                  ),
                  backgroundColor: Colors.green.shade100,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDifficultyIndicator(int difficulty) {
    final color = difficulty <= 2 
      ? Colors.green.shade600 
      : difficulty <= 4 
        ? Colors.orange.shade700 
        : Colors.red.shade600;
    
    return Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          difficulty.toString(),
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.article_outlined,
            size: 70,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  void _showArticleDetails(EcoLearnArticle article) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.9,
          maxChildSize: 0.9,
          minChildSize: 0.5,
          expand: false,
          builder: (context, scrollController) {
            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          article.title,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                ),
                const Divider(),
                if (article.imageUrl != null && article.imageUrl!.isNotEmpty)
                  Image.network(
                    article.imageUrl!,
                    height: 200,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        height: 100,
                        color: Colors.grey.shade200,
                        child: const Center(
                          child: Icon(Icons.image_not_supported, color: Colors.grey),
                        ),
                      );
                    },
                  ),
                Expanded(
                  child: ListView(
                    controller: scrollController,
                    padding: const EdgeInsets.all(16),
                    children: [
                      Text(
                        article.content,
                        style: const TextStyle(fontSize: 16),
                      ),
                      const SizedBox(height: 16),
                      if (article.sourceUrl != null && article.sourceUrl!.isNotEmpty)
                        Row(
                          children: [
                            const Text(
                              'Source: ',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Expanded(
                              child: Text(
                                article.sourceUrl!,
                                style: TextStyle(
                                  color: Colors.blue.shade700,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ),
                          ],
                        ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          const Text(
                            'Created: ',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(article.dateCreated),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}