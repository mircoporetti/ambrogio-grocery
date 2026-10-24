import 'package:ambrogio_grocery/recipes/domain/recipe.dart';
import 'package:ambrogio_grocery/recipes/domain/recipe_id.dart';
import 'package:ambrogio_grocery/recipes/domain/recipe_storage_port.dart';

class FailingRecipeStorageAdapter implements RecipeStoragePort {
  FailingRecipeStorageAdapter(this._real);

  final RecipeStoragePort _real;

  bool failSaves = false;
  bool failDeletes = false;

  @override
  Future<void> save(Recipe recipe) async {
    if (failSaves) throw Exception('Simulated storage failure');
    await _real.save(recipe);
  }

  @override
  Future<void> delete(RecipeId id) async {
    if (failDeletes) throw Exception('Simulated storage failure');
    await _real.delete(id);
  }

  @override
  Future<List<Recipe>> findAll() => _real.findAll();

  @override
  Stream<List<Recipe>> watchAll() => _real.watchAll();

  @override
  Stream<Recipe?> watchById(RecipeId id) => _real.watchById(id);
}
