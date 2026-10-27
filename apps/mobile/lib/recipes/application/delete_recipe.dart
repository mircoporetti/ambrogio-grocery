import 'dart:developer';

import '../domain/photo_storage_port.dart';
import '../domain/recipe.dart';
import '../domain/recipe_storage_port.dart';

class DeleteRecipe {
  DeleteRecipe(this._recipes, this._photos);

  final RecipeStoragePort _recipes;
  final PhotoStoragePort _photos;

  Future<void> call(Recipe recipe) async {
    await _recipes.delete(recipe.id);
    final photo = recipe.photo;
    if (photo == null) return;
    try {
      await _photos.delete(photo);
    } on Exception catch (e, stackTrace) {
      log('Deleting recipe photo failed', error: e, stackTrace: stackTrace);
    }
  }
}
