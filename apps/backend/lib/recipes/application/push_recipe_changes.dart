import '../../accounts/domain/account_id.dart';
import '../../photos/domain/photo_storage_port.dart';
import '../../shared/domain/logger_port.dart';
import '../domain/recipe_change.dart';
import '../domain/recipe_exceptions.dart';
import '../domain/recipe_storage_port.dart';

class PushRecipeChanges {
  PushRecipeChanges(this._recipes, this._photos, this._logger);

  static const maxChanges = 1000;

  final RecipeStoragePort _recipes;
  final PhotoStoragePort _photos;
  final LoggerPort _logger;

  Future<void> call(AccountId account, List<RecipeChange> changes) async {
    if (changes.length > maxChanges) throw const TooManyChangesException();
    if (changes.isEmpty) return;
    final previousPhotos = await _recipes.apply(account, changes);
    final unused = previousPhotos.difference(
      await _recipes.photosInUse(account, previousPhotos),
    );
    for (final photo in unused) {
      // The changes are already saved; a leftover photo only takes space.
      try {
        await _photos.delete(account, photo);
      } on Exception catch (e) {
        _logger.warning('Could not delete photo ${photo.value}: $e');
      }
    }
  }
}
