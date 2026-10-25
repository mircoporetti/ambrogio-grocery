import '../domain/grocery_list_id.dart';
import '../domain/grocery_list_storage_port.dart';

class DeleteGroceryList {
  DeleteGroceryList(this._storage);

  final GroceryListStoragePort _storage;

  Future<void> call(GroceryListId id) => _storage.delete(id);
}
