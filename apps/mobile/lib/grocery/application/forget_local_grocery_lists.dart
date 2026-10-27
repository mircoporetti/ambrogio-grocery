import '../domain/grocery_list_sync_storage_port.dart';

class ForgetLocalGroceryLists {
  ForgetLocalGroceryLists(this._storage);

  final GroceryListSyncStoragePort _storage;

  Future<void> call() => _storage.clear();
}
