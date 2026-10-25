import 'ingredient.dart';
import 'recipe_id.dart';

class Recipe {
  Recipe({
    RecipeId? id,
    required this.title,
    required this.portions,
    required List<Ingredient> ingredients,
    this.procedure,
    this.photoPath,
    List<String> categories = const [],
  }) : id = id ?? RecipeId.generate(),
       ingredients = List.unmodifiable(ingredients),
       categories = List.unmodifiable(distinctCategories(categories)) {
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

  final RecipeId id;
  final String title;
  final int portions;
  final List<Ingredient> ingredients;
  final String? procedure;
  final String? photoPath;
  final List<String> categories;
}

List<String> distinctCategories(Iterable<String> categories) {
  final seen = <String>{};
  return [
    for (final category in categories.map((c) => c.trim()))
      if (category.isNotEmpty && seen.add(category.toLowerCase())) category,
  ];
}
