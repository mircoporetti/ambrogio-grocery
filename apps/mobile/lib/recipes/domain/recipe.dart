import 'ingredient.dart';

class Recipe {
  Recipe({
    required this.title,
    required this.portions,
    required List<Ingredient> ingredients,
    this.procedure,
    this.photoPath,
    List<String> categories = const [],
  }) : ingredients = List.unmodifiable(ingredients),
       categories = List.unmodifiable(categories) {
    if (title.trim().isEmpty) {
      throw ArgumentError.value(title, 'title', 'must not be blank');
    }
    if (portions < 1) {
      throw ArgumentError.value(portions, 'portions', 'must be at least 1');
    }
    if (ingredients.isEmpty) {
      throw ArgumentError.value(
        ingredients,
        'ingredients',
        'must not be empty',
      );
    }
  }

  final String title;
  final int portions;
  final List<Ingredient> ingredients;
  final String? procedure;
  final String? photoPath;
  final List<String> categories;
}
