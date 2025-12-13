import 'package:flutter/material.dart';
import '../models/category.dart';
import '../services/meal_api_service.dart';
import '../widgets/category_card.dart';
import 'meals_by_category_screen.dart';
import 'meals_detail_screen.dart';
import 'favourites_screen.dart';
import '../services/fcm_service.dart';
import '../services/notifications_service.dart';
import 'package:flutter/foundation.dart' show kIsWeb;






class CategoriesScreen extends StatefulWidget {
  const CategoriesScreen({super.key});

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  final MealApiService apiService = MealApiService();
  final _fcm = FcmService();
  final _notifs = NotificationsService();

  List<Category> _categories = [];
  List<Category> _filtered = [];
  bool _isLoading = true;
  //String _searchQuery = '';


  @override
  void initState() {
    super.initState();
    _loadCategories();
    _setupNotifications();
    
  }

//lab 4 notif
Future<void> _setupNotifications() async {
  // Firebase Messaging (FCM) НЕ го пуштаме на Web за да нема failed-service-worker error
  if (kIsWeb) {
    debugPrint('Skipping FCM on Web (service worker/push not configured).');
    return;
  }

  try {
    await _fcm.init();
    final token = await _fcm.getToken();
    debugPrint('FCM TOKEN: $token');

    await _notifs.init();
    await _notifs.scheduleDailyReminder(hour: 19, minute: 27);
  } catch (e) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Notification setup error: $e')),
    );
  }
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

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  void _filterCategories(String query) {
    setState(() {
     // _searchQuery = query;
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
      // lab 4
      appBar: AppBar(
          title: const Text('Categories'),
          actions: [
            IconButton(
              icon: const Icon(Icons.favorite),
              tooltip: 'Favorites',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const FavoritesScreen(),
                  ),
                );
              },
            ),
          ],
        ),
body: Column(
  children: [
    Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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

    // za random meal
    Padding(
      padding: const EdgeInsets.all(12.0),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          onPressed: _openRandomMeal,
          icon: const Icon(Icons.shuffle),
          label: const Text(
            'Random Recipe of the Day :)',
            style: TextStyle(fontSize: 16),
          ),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 14),
          ),
        ),
      ),
    ),
  ],
),

    );
  }
}
