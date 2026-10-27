import 'ingredient.dart';
import 'photo_id.dart';
import 'recipe_exceptions.dart';

class Recipe {
  Recipe({
    required this.title,
    required this.portions,
    required List<Ingredient> ingredients,
    this.procedure,
    this.photoId,
    List<String> categories = const [],
  }) : ingredients = List.unmodifiable(ingredients),
       categories = List.unmodifiable(_distinct(categories)) {
    if (title.trim().isEmpty) {
      throw const InvalidRecipeException('title must not be blank');
    }
    if (portions < 1) {
      throw const InvalidRecipeException('portions must be at least 1');
    }
    if (ingredients.isEmpty) {
      throw const InvalidRecipeException('ingredients must not be empty');
    }
  }

  final String title;
  final int portions;
  final List<Ingredient> ingredients;
  final String? procedure;
  final PhotoId? photoId;
  final List<String> categories;

  static List<String> _distinct(Iterable<String> categories) {
    final seen = <String>{};
    return [
      for (final category in categories.map((c) => c.trim()))
        if (category.isNotEmpty && seen.add(category.toLowerCase())) category,
    ];
  }
}
