import '../domain/recipe.dart';
import '../domain/recipe_storage_port.dart';

class ListRecipes {
  ListRecipes(this._storage);

  final RecipeStoragePort _storage;

  Future<List<Recipe>> call() => _storage.findAll();
}
