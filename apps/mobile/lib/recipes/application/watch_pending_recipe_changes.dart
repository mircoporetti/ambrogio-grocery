import '../domain/recipe_sync_storage_port.dart';

class WatchPendingRecipeChanges {
  WatchPendingRecipeChanges(this._storage);

  final RecipeSyncStoragePort _storage;

  Stream<int> call() => _storage.watchPendingCount();
}
