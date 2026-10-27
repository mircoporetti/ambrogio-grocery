import 'dart:developer';

import '../domain/photo_storage_port.dart';
import '../domain/recipe_storage_port.dart';
import '../domain/recipe_sync_storage_port.dart';

class ForgetLocalRecipes {
  ForgetLocalRecipes(this._recipes, this._sync, this._photos);

  final RecipeStoragePort _recipes;
  final RecipeSyncStoragePort _sync;
  final PhotoStoragePort _photos;

  Future<void> call() async {
    final photos = [
      for (final recipe in await _recipes.findAll()) ?recipe.photo,
    ];
    await _sync.clear();
    for (final photo in photos) {
      try {
        await _photos.delete(photo);
      } on Exception catch (e, stackTrace) {
        log('Deleting a photo failed', error: e, stackTrace: stackTrace);
      }
    }
  }
}
