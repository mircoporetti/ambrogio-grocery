import 'dart:developer';

import '../domain/photo_storage_port.dart';
import '../domain/recipe.dart';
import '../domain/recipe_storage_port.dart';

class UpdateRecipe {
  UpdateRecipe(this._recipes, this._photos);

  final RecipeStoragePort _recipes;
  final PhotoStoragePort _photos;

  Future<void> call(Recipe recipe) async {
    final previous = await _recipes.findById(recipe.id);
    await _recipes.save(recipe);
    final oldPhoto = previous?.photoPath;
    if (oldPhoto == null || oldPhoto == recipe.photoPath) return;
    try {
      await _photos.delete(oldPhoto);
    } on Exception catch (e, stackTrace) {
      log('Deleting replaced photo failed', error: e, stackTrace: stackTrace);
    }
  }
}
