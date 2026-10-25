import '../../recipes/domain/ingredient.dart';
import '../../recipes/domain/recipe.dart';
import 'grocery_item.dart';
import 'grocery_list_id.dart';
import 'week.dart';

class GroceryList {
  GroceryList({
    GroceryListId? id,
    required this.week,
    required List<String> recipes,
    required List<GroceryItem> items,
  }) : id = id ?? GroceryListId.generate(),
       recipes = List.unmodifiable(recipes),
       items = List.unmodifiable(items) {
    if (recipes.isEmpty) {
      throw ArgumentError.value(recipes, 'recipes', 'must not be empty');
    }
    if (items.isEmpty) {
      throw ArgumentError.value(items, 'items', 'must not be empty');
    }
  }

  factory GroceryList.plan(Week week, List<Recipe> recipes) {
    final merged = <(String, MeasureUnit), Ingredient>{};
    for (final ingredient in recipes.expand((r) => r.ingredients)) {
      final name = ingredient.name.trim();
      final key = (name.toLowerCase(), ingredient.unit);
      final existing = merged[key];
      merged[key] = Ingredient(
        name: existing?.name ?? name,
        quantity: (existing?.quantity ?? 0) + ingredient.quantity,
        unit: ingredient.unit,
      );
    }
    final keys = merged.keys.toList()
      ..sort((a, b) {
        final byName = a.$1.compareTo(b.$1);
        return byName != 0 ? byName : a.$2.index.compareTo(b.$2.index);
      });
    return GroceryList(
      week: week,
      recipes: [for (final recipe in recipes) recipe.title],
      items: [for (final key in keys) GroceryItem(merged[key]!)],
    );
  }

  final GroceryListId id;
  final Week week;
  final List<String> recipes;
  final List<GroceryItem> items;
}
