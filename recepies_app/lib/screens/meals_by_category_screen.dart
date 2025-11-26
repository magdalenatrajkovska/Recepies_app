import 'package:flutter/material.dart';
import 'package:recepies_app/screens/meals_detail_screen.dart';
import '../models/meal_summary.dart';
import '../services/meal_api_service.dart';
import '../widgets/meal_card.dart';

class MealsByCategoryScreen extends StatefulWidget {
  final String categoryName;

  const MealsByCategoryScreen({
    super.key,
    required this.categoryName,
  });

  @override
  State<MealsByCategoryScreen> createState() => _MealsByCategoryScreenState();
}

class _MealsByCategoryScreenState extends State<MealsByCategoryScreen> {
  final MealApiService apiService = MealApiService();
  List<MealSummary> _meals = [];
  List<MealSummary> _filtered = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadMeals();
  }

  Future<void> _loadMeals() async {
    try {
      final meals = await apiService.fetchMealsByCategory(widget.categoryName);
      setState(() {
        _meals = meals;
        _filtered = meals;
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

  void _filterMealsLocal(String query) {
    setState(() {
      _filtered = _meals
          .where((m) =>
              m.name.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.categoryName),
      ),
      body: Column(
        children: [
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: TextField(
              decoration: const InputDecoration(
                labelText: 'Search meals in this category',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: _filterMealsLocal,
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : GridView.builder(
                    padding: const EdgeInsets.all(8),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.75,
                      crossAxisSpacing: 8,
                      mainAxisSpacing: 8,
                    ),
                    itemCount: _filtered.length,
                    itemBuilder: (context, index) {
                      final meal = _filtered[index];
                      return MealCard(
                        meal: meal,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  MealDetailScreen(mealId: meal.id),
                            ),
                          );
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
