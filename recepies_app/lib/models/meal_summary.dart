class MealSummary {
  final String id;
  final String name;
  final String thumbnail;

  MealSummary({
    required this.id,
    required this.name,
    required this.thumbnail,
  });

  factory MealSummary.fromJson(Map<String, dynamic> json) {
    return MealSummary(
      id: json['idMeal'] as String,
      name: json['strMeal'] as String,
      thumbnail: json['strMealThumb'] as String,
    );
  }
}
