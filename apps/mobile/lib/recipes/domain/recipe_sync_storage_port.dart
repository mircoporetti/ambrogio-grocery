import 'photo.dart';
import 'photo_id.dart';
import 'recipe_change.dart';

abstract interface class RecipeSyncStoragePort {
  Future<List<RecipeChange>> pendingChanges();

  Stream<int> watchPendingCount();

  Future<void> markPushed(List<RecipeChange> changes);

  Future<List<Photo>> applyPulled(RecipeChangesPage page);

  Future<String?> cursor();

  Future<List<Photo>> photosToUpload();

  Future<void> stopUploadingPhoto(PhotoId id);

  Future<List<PhotoId>> photosToDownload();

  Future<bool> savePhotoPath(PhotoId id, String path);

  Future<void> clear();
}
