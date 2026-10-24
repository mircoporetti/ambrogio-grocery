import '../domain/recipe.dart';
import '../domain/recipe_id.dart';
import '../domain/recipe_storage_port.dart';

class WatchRecipe {
  WatchRecipe(this._storage);

  final RecipeStoragePort _storage;

  Stream<Recipe?> call(RecipeId id) => _storage.watchById(id);
}
