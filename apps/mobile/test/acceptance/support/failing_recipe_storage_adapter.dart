import 'package:ambrogio_grocery/recipes/domain/recipe.dart';
import 'package:ambrogio_grocery/recipes/domain/recipe_storage_port.dart';

class FailingRecipeStorageAdapter implements RecipeStoragePort {
  FailingRecipeStorageAdapter(this._real);

  final RecipeStoragePort _real;

  bool failSaves = false;

  @override
  Future<void> save(Recipe recipe) async {
    if (failSaves) throw Exception('Simulated storage failure');
    await _real.save(recipe);
  }

  @override
  Future<List<Recipe>> findAll() => _real.findAll();

  @override
  Stream<List<Recipe>> watchAll() => _real.watchAll();
}
