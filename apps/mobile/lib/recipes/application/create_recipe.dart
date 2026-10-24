import '../domain/recipe.dart';
import '../domain/recipe_storage_port.dart';

class CreateRecipe {
  CreateRecipe(this._storage);

  final RecipeStoragePort _storage;

  Future<void> call(Recipe recipe) => _storage.save(recipe);
}
