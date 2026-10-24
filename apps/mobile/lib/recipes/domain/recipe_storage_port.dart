import 'recipe.dart';
import 'recipe_id.dart';

abstract interface class RecipeStoragePort {
  Future<List<Recipe>> findAll();

  Stream<List<Recipe>> watchAll();

  Stream<Recipe?> watchById(RecipeId id);

  Future<void> save(Recipe recipe);
}
