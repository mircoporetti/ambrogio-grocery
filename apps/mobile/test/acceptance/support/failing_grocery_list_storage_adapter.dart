import 'package:ambrogio_grocery/grocery/domain/grocery_item_id.dart';
import 'package:ambrogio_grocery/grocery/domain/grocery_list.dart';
import 'package:ambrogio_grocery/grocery/domain/grocery_list_id.dart';
import 'package:ambrogio_grocery/grocery/domain/grocery_list_storage_port.dart';
import 'package:ambrogio_grocery/grocery/domain/week.dart';

class FailingGroceryListStorageAdapter implements GroceryListStoragePort {
  FailingGroceryListStorageAdapter(this._real);

  final GroceryListStoragePort _real;

  bool failSaves = false;
  bool failDeletes = false;

  @override
  Future<void> delete(GroceryListId id) async {
    if (failDeletes) throw Exception('Simulated storage failure');
    await _real.delete(id);
  }

  @override
  Future<void> save(GroceryList list) async {
    if (failSaves) throw Exception('Simulated storage failure');
    await _real.save(list);
  }

  @override
  Future<void> tickItem(
    GroceryListId id,
    GroceryItemId item, {
    required bool ticked,
  }) async {
    if (failSaves) throw Exception('Simulated storage failure');
    await _real.tickItem(id, item, ticked: ticked);
  }

  @override
  Future<List<GroceryList>> findAll() => _real.findAll();

  @override
  Future<GroceryList?> findByWeek(Week week) => _real.findByWeek(week);

  @override
  Stream<GroceryList?> watchByWeek(Week week) => _real.watchByWeek(week);

  @override
  Stream<List<GroceryList>> watchFrom(Week week) => _real.watchFrom(week);
}
