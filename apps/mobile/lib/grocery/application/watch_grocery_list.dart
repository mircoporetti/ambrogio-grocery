import '../domain/grocery_list.dart';
import '../domain/grocery_list_storage_port.dart';
import '../domain/week.dart';

class WatchGroceryList {
  WatchGroceryList(this._storage);

  final GroceryListStoragePort _storage;

  Stream<GroceryList?> call(Week week) => _storage.watchByWeek(week);
}
