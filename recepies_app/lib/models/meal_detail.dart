class MealDetail {
  final String id;
  final String name;
  final String thumbnail;
  final String instructions;
  final String? youtubeUrl;
  final List<Map<String, String>> ingredients;

  MealDetail({
    required this.id,
    required this.name,
    required this.thumbnail,
    required this.instructions,
    required this.youtubeUrl,
    required this.ingredients,
  });

  factory MealDetail.fromJson(Map<String, dynamic> json) {
    final List<Map<String, String>> ingrs = [];

    for (int i = 1; i <= 20; i++) {
      final ingredient = json['strIngredient$i'];
      final measure = json['strMeasure$i'];

      if (ingredient != null &&
          ingredient.toString().trim().isNotEmpty) {
        ingrs.add({
          'ingredient': ingredient.toString(),
          'measure': (measure ?? '').toString(),
        });
      }
    }

    return MealDetail(
      id: json['idMeal'] as String,
      name: json['strMeal'] as String,
      thumbnail: json['strMealThumb'] as String,
      instructions: json['strInstructions'] as String,
      youtubeUrl: json['strYoutube'] as String?,
      ingredients: ingrs,
    );
  }
}
