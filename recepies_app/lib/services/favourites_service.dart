import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/meal_summary.dart';

class FavoritesService {
  static const _key = 'favorites_meals';

  Future<List<MealSummary>> getFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null) return [];

    final list = (jsonDecode(raw) as List).cast<Map<String, dynamic>>();
    return list.map((e) => MealSummary(
      id: e['id'] as String,
      name: e['name'] as String,
      thumbnail: e['thumbnail'] as String,
    )).toList();
  }

  Future<bool> isFavorite(String mealId) async {
    final favs = await getFavorites();
    return favs.any((m) => m.id == mealId);
  }

  Future<void> toggleFavorite(MealSummary meal) async {
    final prefs = await SharedPreferences.getInstance();
    final favs = await getFavorites();

    final idx = favs.indexWhere((m) => m.id == meal.id);
    if (idx >= 0) {
      favs.removeAt(idx);
    } else {
      favs.add(meal);
    }

    final encoded = jsonEncode(
      favs.map((m) => {
        'id': m.id,
        'name': m.name,
        'thumbnail': m.thumbnail,
      }).toList(),
    );

    await prefs.setString(_key, encoded);
  }
}
