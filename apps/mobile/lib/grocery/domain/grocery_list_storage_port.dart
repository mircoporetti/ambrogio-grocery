import 'grocery_list.dart';
import 'grocery_list_id.dart';
import 'week.dart';

abstract interface class GroceryListStoragePort {
  Future<void> save(GroceryList list);

  Future<void> tickItem(GroceryListId id, int index, {required bool ticked});

  Future<List<GroceryList>> findAll();

  Future<GroceryList?> findByWeek(Week week);

  Stream<GroceryList?> watchByWeek(Week week);

  Stream<List<GroceryList>> watchFrom(Week week);
}
