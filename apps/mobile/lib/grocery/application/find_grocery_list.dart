import '../domain/grocery_list.dart';
import '../domain/grocery_list_storage_port.dart';
import '../domain/week.dart';

class FindGroceryList {
  FindGroceryList(this._storage);

  final GroceryListStoragePort _storage;

  Future<GroceryList?> call(Week week) => _storage.findByWeek(week);
}
