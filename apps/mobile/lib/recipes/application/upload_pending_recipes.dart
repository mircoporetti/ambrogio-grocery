import '../domain/recipe_sync_storage_port.dart';
import 'sync_recipes.dart';

class UploadPendingRecipes {
  UploadPendingRecipes(this._storage, this._sync);

  final RecipeSyncStoragePort _storage;
  final SyncRecipes _sync;

  /// Returns false if some changes are still only on the phone.
  Future<bool> call() async {
    if ((await _storage.pendingChanges()).isEmpty) return true;
    await _sync();
    return (await _storage.pendingChanges()).isEmpty;
  }
}
