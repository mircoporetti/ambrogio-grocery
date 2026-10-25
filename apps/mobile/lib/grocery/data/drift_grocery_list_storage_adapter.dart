import 'package:drift/drift.dart';

import '../../database/app_database.dart';
import '../../recipes/domain/ingredient.dart';
import '../domain/grocery_item.dart';
import '../domain/grocery_list.dart';
import '../domain/grocery_list_id.dart';
import '../domain/grocery_list_storage_port.dart';
import '../domain/week.dart';

class DriftGroceryListStorageAdapter implements GroceryListStoragePort {
  DriftGroceryListStorageAdapter(this._db);

  final AppDatabase _db;

  static String _weekKey(Week week) =>
      week.start.toIso8601String().substring(0, 10);

  static Week _weekFrom(String key) => Week.startingOn(DateTime.parse(key));

  @override
  Future<void> save(GroceryList list) => _db.transaction(() async {
    final weekKey = _weekKey(list.week);
    await (_db.delete(_db.groceryLists)..where(
          (l) => l.weekStart.equals(weekKey) | l.uuid.equals(list.id.value),
        ))
        .go();
    final listId = await _db
        .into(_db.groceryLists)
        .insert(
          GroceryListsCompanion.insert(uuid: list.id.value, weekStart: weekKey),
        );
    await _db.batch((batch) {
      batch.insertAll(_db.groceryListRecipes, [
        for (final (position, title) in list.recipes.indexed)
          GroceryListRecipesCompanion.insert(
            listId: listId,
            position: position,
            title: title,
          ),
      ]);
      batch.insertAll(_db.groceryListItems, [
        for (final (position, item) in list.items.indexed)
          GroceryListItemsCompanion.insert(
            listId: listId,
            position: position,
            name: item.ingredient.name,
            quantity: item.ingredient.quantity,
            unit: item.ingredient.unit.name,
            ticked: Value(item.ticked),
          ),
      ]);
    });
  });

  @override
  Future<void> tickItem(GroceryListId id, int index, {required bool ticked}) =>
      _db.transaction(() async {
        final list = await (_db.select(
          _db.groceryLists,
        )..where((l) => l.uuid.equals(id.value))).getSingleOrNull();
        if (list == null) throw StateError('No grocery list $id');
        final updated =
            await (_db.update(_db.groceryListItems)..where(
                  (i) => i.listId.equals(list.id) & i.position.equals(index),
                ))
                .write(GroceryListItemsCompanion(ticked: Value(ticked)));
        if (updated == 0) {
          throw StateError('No item $index in grocery list $id');
        }
      });

  Stream<void> _changes() => _db
      .customSelect(
        'SELECT 1 AS grocery_lists_changed',
        readsFrom: {
          _db.groceryLists,
          _db.groceryListRecipes,
          _db.groceryListItems,
        },
      )
      .watch();

  @override
  Future<List<GroceryList>> findAll() => _load();

  @override
  Future<GroceryList?> findByWeek(Week week) async =>
      (await _load(week: week)).firstOrNull;

  @override
  Stream<GroceryList?> watchByWeek(Week week) =>
      _changes().asyncMap((_) => findByWeek(week));

  @override
  Stream<List<GroceryList>> watchFrom(Week week) =>
      _changes().asyncMap((_) => _load(from: week));

  Future<List<GroceryList>> _load({Week? week, Week? from}) =>
      _db.transaction(() async {
        final listQuery = _db.select(_db.groceryLists)
          ..orderBy([(l) => OrderingTerm.asc(l.weekStart)]);
        if (week != null) {
          listQuery.where((l) => l.weekStart.equals(_weekKey(week)));
        }
        if (from != null) {
          listQuery.where(
            (l) => l.weekStart.isBiggerOrEqualValue(_weekKey(from)),
          );
        }
        final lists = await listQuery.get();
        if (lists.isEmpty) return const <GroceryList>[];

        final rowIds = lists.map((l) => l.id).toList();
        final recipes =
            await (_db.select(_db.groceryListRecipes)
                  ..where((r) => r.listId.isIn(rowIds))
                  ..orderBy([(r) => OrderingTerm.asc(r.position)]))
                .get();
        final items =
            await (_db.select(_db.groceryListItems)
                  ..where((i) => i.listId.isIn(rowIds))
                  ..orderBy([(i) => OrderingTerm.asc(i.position)]))
                .get();

        final recipesByList = <int, List<String>>{};
        for (final row in recipes) {
          recipesByList.putIfAbsent(row.listId, () => []).add(row.title);
        }
        final itemsByList = <int, List<GroceryItem>>{};
        for (final row in items) {
          itemsByList
              .putIfAbsent(row.listId, () => [])
              .add(
                GroceryItem(
                  Ingredient(
                    name: row.name,
                    quantity: row.quantity,
                    unit: MeasureUnit.values.byName(row.unit),
                  ),
                  ticked: row.ticked,
                ),
              );
        }

        return [
          for (final row in lists)
            GroceryList(
              id: GroceryListId(row.uuid),
              week: _weekFrom(row.weekStart),
              recipes: recipesByList[row.id] ?? const [],
              items: itemsByList[row.id] ?? const [],
            ),
        ];
      });
}
