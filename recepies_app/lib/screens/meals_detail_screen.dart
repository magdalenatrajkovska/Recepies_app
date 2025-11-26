import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/meal_detail.dart';
import '../services/meal_api_service.dart';

class MealDetailScreen extends StatefulWidget {
  final String mealId;

  const MealDetailScreen({
    super.key,
    required this.mealId,
  });

  @override
  State<MealDetailScreen> createState() => _MealDetailScreenState();
}

class _MealDetailScreenState extends State<MealDetailScreen> {
  final MealApiService apiService = MealApiService();
  MealDetail? _meal;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadMealDetail();
  }

  Future<void> _loadMealDetail() async {
    try {
      final meal = await apiService.fetchMealDetail(widget.mealId);
      setState(() {
        _meal = meal;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  Future<void> _openYoutube() async {
    if (_meal?.youtubeUrl == null ||
        _meal!.youtubeUrl!.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No YouTube link available.')),
      );
      return;
    }

    final uri = Uri.parse(_meal!.youtubeUrl!);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open YouTube link.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_meal == null) {
      return const Scaffold(
        body: Center(child: Text('Meal not found')),
      );
    }

    final meal = _meal!;

    return Scaffold(
      appBar: AppBar(
        title: Text(meal.name),
        actions: [
          if (meal.youtubeUrl != null && meal.youtubeUrl!.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.video_library),
              onPressed: _openYoutube,
            ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.network(meal.thumbnail),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    meal.name,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Ingredients:',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ...meal.ingredients.map(
                    (ing) => Text(
                      '- ${ing['ingredient']} (${ing['measure']})',
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Instructions:',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(meal.instructions),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
