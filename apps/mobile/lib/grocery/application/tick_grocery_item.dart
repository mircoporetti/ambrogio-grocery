import '../domain/grocery_list_id.dart';
import '../domain/grocery_list_storage_port.dart';

class TickGroceryItem {
  TickGroceryItem(this._storage);

  final GroceryListStoragePort _storage;

  Future<void> call(GroceryListId id, int index, {required bool ticked}) =>
      _storage.tickItem(id, index, ticked: ticked);
}
