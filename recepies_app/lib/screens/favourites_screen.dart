import 'package:flutter/material.dart';
import '../models/meal_summary.dart';
import '../services/favourites_service.dart';
import 'meals_detail_screen.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  final FavoritesService favoritesService = FavoritesService();
  bool _loading = true;
  List<MealSummary> _items = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final favs = await favoritesService.getFavorites();
    if (!mounted) return;
    setState(() {
      _items = favs;
      _loading = false;
    });
  }

  Future<void> _remove(MealSummary meal) async {
    await favoritesService.toggleFavorite(meal); // toggle = remove ако постои
    await _load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Favorites')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _items.isEmpty
              ? const Center(child: Text('No favorites yet ❤️'))
              : RefreshIndicator(
                  onRefresh: _load,
                  child: ListView.builder(
                    itemCount: _items.length,
                    itemBuilder: (context, i) {
                      final m = _items[i];
                      return Card(
                        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        child: ListTile(
                          leading: Image.network(m.thumbnail, width: 56, fit: BoxFit.cover),
                          title: Text(m.name),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => MealDetailScreen(mealId: m.id),
                              ),
                            );
                          },
                          trailing: IconButton(
                            icon: const Icon(Icons.delete_outline),
                            onPressed: () => _remove(m),
                          ),
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}
