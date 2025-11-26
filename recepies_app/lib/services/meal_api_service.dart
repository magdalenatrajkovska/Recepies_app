import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/category.dart';
import '../models/meal_summary.dart';
import '../models/meal_detail.dart';

class MealApiService {
  static const String baseUrl = 'https://www.themealdb.com/api/json/v1/1';

  Future<List<Category>> fetchCategories() async {
    final url = Uri.parse('$baseUrl/categories.php');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List categoriesJson = data['categories'];
      return categoriesJson
          .map((json) => Category.fromJson(json))
          .toList();
    } else {
      throw Exception('Failed to load categories');
    }
  }

  Future<List<MealSummary>> fetchMealsByCategory(String category) async {
    final url = Uri.parse('$baseUrl/filter.php?c=$category');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List mealsJson = data['meals'] ?? [];
      return mealsJson
          .map((json) => MealSummary.fromJson(json))
          .toList();
    } else {
      throw Exception('Failed to load meals');
    }
  }

  Future<List<MealSummary>> searchMeals(String query) async {
    final url = Uri.parse('$baseUrl/search.php?s=$query');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List? mealsJson = data['meals'];
      if (mealsJson == null) return [];
      return mealsJson
          .map((json) => MealSummary.fromJson(json))
          .toList();
    } else {
      throw Exception('Failed to search meals');
    }
  }

  Future<MealDetail> fetchMealDetail(String id) async {
    final url = Uri.parse('$baseUrl/lookup.php?i=$id');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List mealsJson = data['meals'];
      return MealDetail.fromJson(mealsJson[0]);
    } else {
      throw Exception('Failed to load meal detail');
    }
  }

  Future<MealDetail> fetchRandomMeal() async {
    final url = Uri.parse('$baseUrl/random.php');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List mealsJson = data['meals'];
      return MealDetail.fromJson(mealsJson[0]);
    } else {
      throw Exception('Failed to load random meal');
    }
  }
}
