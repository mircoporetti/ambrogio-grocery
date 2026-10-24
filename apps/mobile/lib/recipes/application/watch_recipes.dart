import '../domain/recipe.dart';
import '../domain/recipe_storage_port.dart';

class WatchRecipes {
  WatchRecipes(this._storage);

  final RecipeStoragePort _storage;

  Stream<List<Recipe>> call() => _storage.watchAll();
}
