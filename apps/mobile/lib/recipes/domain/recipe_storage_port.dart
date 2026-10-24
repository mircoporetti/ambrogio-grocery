import 'recipe.dart';

abstract interface class RecipeStoragePort {
  Future<List<Recipe>> findAll();

  /// Emits all recipes now, and again every time they change.
  Stream<List<Recipe>> watchAll();

  Future<void> save(Recipe recipe);
}
