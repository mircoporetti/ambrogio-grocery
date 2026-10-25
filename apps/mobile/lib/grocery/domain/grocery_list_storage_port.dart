import 'grocery_list.dart';
import 'week.dart';

abstract interface class GroceryListStoragePort {
  Future<void> save(GroceryList list);

  Future<List<GroceryList>> findAll();

  Future<GroceryList?> findByWeek(Week week);

  Stream<GroceryList?> watchByWeek(Week week);

  Stream<List<GroceryList>> watchFrom(Week week);
}
