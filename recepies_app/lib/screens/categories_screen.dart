import 'package:flutter/material.dart';
import '../models/category.dart';
import '../services/meal_api_service.dart';
import '../widgets/category_card.dart';
import 'meals_by_category_screen.dart';
import 'meals_detail_screen.dart';

class CategoriesScreen extends StatefulWidget {
  const CategoriesScreen({super.key});

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  final MealApiService apiService = MealApiService();
  List<Category> _categories = [];
  List<Category> _filtered = [];
  bool _isLoading = true;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    try {
      final cats = await apiService.fetchCategories();
      setState(() {
        _categories = cats;
        _filtered = cats;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      // за лабот е доволно Snackbar
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  void _filterCategories(String query) {
    setState(() {
      _searchQuery = query;
      _filtered = _categories
          .where((c) =>
              c.name.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  Future<void> _openRandomMeal() async {
    try {
      final randomMeal = await apiService.fetchRandomMeal();
      if (!mounted) return;
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => MealDetailScreen(mealId: randomMeal.id),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading random meal: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Categories'),
        actions: [
          IconButton(
            onPressed: _openRandomMeal,
            icon: const Icon(Icons.shuffle),
            tooltip: 'Random recipe of the day',
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: TextField(
              decoration: const InputDecoration(
                labelText: 'Search categories',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: _filterCategories,
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    itemCount: _filtered.length,
                    itemBuilder: (context, index) {
                      final cat = _filtered[index];
                      return CategoryCard(
                        category: cat,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => MealsByCategoryScreen(
                                categoryName: cat.name,
                              ),
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
