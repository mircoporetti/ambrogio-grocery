import '../../grocery/domain/grocery_list_sync_storage_port.dart';
import '../../recipes/domain/recipe_sync_storage_port.dart';
import 'sync_all.dart';

class UploadPendingChanges {
  UploadPendingChanges(this._recipes, this._groceryLists, this._sync);

  final RecipeSyncStoragePort _recipes;
  final GroceryListSyncStoragePort _groceryLists;
  final SyncAll _sync;

  Future<bool> call() async {
    if (await _nothingPending()) return true;
    await _sync();
    return _nothingPending();
  }

  Future<bool> _nothingPending() async =>
      (await _recipes.pendingChanges()).isEmpty &&
      (await _groceryLists.pendingChanges()).isEmpty;
}
