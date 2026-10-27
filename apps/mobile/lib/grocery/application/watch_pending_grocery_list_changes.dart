import '../domain/grocery_list_sync_storage_port.dart';

class WatchPendingGroceryListChanges {
  WatchPendingGroceryListChanges(this._storage);

  final GroceryListSyncStoragePort _storage;

  Stream<int> call() => _storage.watchPendingCount();
}
