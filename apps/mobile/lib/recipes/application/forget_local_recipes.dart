import 'dart:developer';

import '../domain/photo_storage_port.dart';
import '../domain/recipe_storage_port.dart';
import '../domain/recipe_sync_storage_port.dart';
import 'recipe_sync_lock.dart';

class ForgetLocalRecipes {
  ForgetLocalRecipes(this._recipes, this._sync, this._photos, this._lock);

  final RecipeStoragePort _recipes;
  final RecipeSyncStoragePort _sync;
  final PhotoStoragePort _photos;
  final RecipeSyncLock _lock;

  Future<void> call() => _lock.run(() async {
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
  });
}
