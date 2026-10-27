import 'dart:math';

import 'package:drift/drift.dart';

import '../../database/app_database.dart';
import '../../recipes/domain/ingredient.dart';
import '../domain/grocery_item.dart';
import '../domain/grocery_item_id.dart';
import '../domain/grocery_list.dart';
import '../domain/grocery_list_change.dart';
import '../domain/grocery_list_id.dart';
import '../domain/grocery_list_storage_port.dart';
import '../domain/grocery_list_sync_storage_port.dart';
import '../domain/week.dart';

class DriftGroceryListStorageAdapter
    implements GroceryListStoragePort, GroceryListSyncStoragePort {
  DriftGroceryListStorageAdapter(this._db);

  final AppDatabase _db;

  static const _cursorName = 'grocery_lists';

  @override
  Future<void> save(GroceryList list) => _db.transaction(() async {
    final updatedAt = await _nextUpdatedAt(list.week);
    await _write(list, updatedAt);
    await _markPending(list.week, updatedAt);
  });

  @override
  Future<void> delete(GroceryListId id) => _db.transaction(() async {
    final row = await _rowById(id);
    if (row == null) return;
    final week = Week.fromKey(row.weekStart);
    final updatedAt = await _nextUpdatedAt(week);
    await (_db.delete(
      _db.groceryLists,
    )..where((l) => l.id.equals(row.id))).go();
    await _markPending(week, updatedAt);
  });

  @override
  Future<void> tickItem(
    GroceryListId id,
    GroceryItemId item, {
    required bool ticked,
  }) => _db.transaction(() async {
    final list = await _rowById(id);
    if (list == null) throw StateError('No grocery list $id');
    final row =
        await (_db.select(_db.groceryListItems)..where(
              (i) => i.listId.equals(list.id) & i.uuid.equals(item.value),
            ))
            .getSingleOrNull();
    if (row == null) throw StateError('No item $item in grocery list $id');
    final now = DateTime.now().toUtc().microsecondsSinceEpoch;
    await (_db.update(
      _db.groceryListItems,
    )..where((i) => i.id.equals(row.id))).write(
      GroceryListItemsCompanion(
        ticked: Value(ticked),
        // Never before the last tick: another phone's clock may run ahead.
        tickedAt: Value(
          row.tickedAt == null ? now : max(now, row.tickedAt! + 1),
        ),
      ),
    );
    await _markPending(Week.fromKey(list.weekStart), list.updatedAt);
  });

  Future<GroceryListRow?> _rowById(GroceryListId id) => (_db.select(
    _db.groceryLists,
  )..where((l) => l.uuid.equals(id.value))).getSingleOrNull();

  /// Never before the last change: another phone's clock may run ahead.
  Future<int> _nextUpdatedAt(Week week) async {
    final now = DateTime.now().toUtc().microsecondsSinceEpoch;
    final last = (await _localChange(week))?.updatedAt;
    return last == null ? now : max(now, _micros(last) + 1);
  }

  Future<void> _markPending(Week week, int updatedAt) => _db
      .into(_db.pendingGroceryListChanges)
      .insertOnConflictUpdate(
        PendingGroceryListChangesCompanion.insert(
          weekStart: week.key,
          updatedAt: updatedAt,
        ),
      );

  Future<void> _write(GroceryList list, int updatedAt) async {
    final weekKey = list.week.key;
    await (_db.delete(_db.groceryLists)..where(
          (l) => l.weekStart.equals(weekKey) | l.uuid.equals(list.id.value),
        ))
        .go();
    final listId = await _db
        .into(_db.groceryLists)
        .insert(
          GroceryListsCompanion.insert(
            uuid: list.id.value,
            weekStart: weekKey,
            updatedAt: Value(updatedAt),
          ),
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
            uuid: item.id.value,
            name: item.ingredient.name,
            quantity: item.ingredient.quantity,
            unit: item.ingredient.unit.name,
            ticked: Value(item.ticked),
            tickedAt: Value(switch (item.tickedAt) {
              null => null,
              final at => _micros(at),
            }),
          ),
      ]);
    });
  }

  Future<GroceryListChange?> _localChange(Week week) async {
    final row = await (_db.select(
      _db.groceryLists,
    )..where((l) => l.weekStart.equals(week.key))).getSingleOrNull();
    if (row != null) {
      return GroceryListChange(
        week: week,
        updatedAt: _time(row.updatedAt),
        list: (await _load(week: week)).single,
      );
    }
    final pending = await (_db.select(
      _db.pendingGroceryListChanges,
    )..where((c) => c.weekStart.equals(week.key))).getSingleOrNull();
    if (pending == null) return null;
    return GroceryListChange(week: week, updatedAt: _time(pending.updatedAt));
  }

  @override
  Future<List<GroceryListChange>> pendingChanges() => _db.transaction(() async {
    final pending = await (_db.select(
      _db.pendingGroceryListChanges,
    )..orderBy([(c) => OrderingTerm.asc(c.weekStart)])).get();
    return [
      for (final row in pending)
        (await _localChange(Week.fromKey(row.weekStart)))!,
    ];
  });

  @override
  Stream<int> watchPendingCount() {
    final count = countAll();
    return (_db.selectOnly(
      _db.pendingGroceryListChanges,
    )..addColumns([count])).map((row) => row.read(count)!).watchSingle();
  }

  @override
  Future<void> markPushed(List<GroceryListChange> changes) =>
      _db.transaction(() async {
        for (final pushed in changes) {
          // A tick or a new planning made during the push keeps it pending.
          final current = await _localChange(pushed.week);
          if (current == null || !current.sameStateAs(pushed)) continue;
          await _forgetPending(pushed.week);
        }
      });

  @override
  Future<void> applyPulled(GroceryListChangesPage page) => _db.transaction(
    () async {
      for (final pulled in page.changes) {
        final result = pulled.applyTo(await _localChange(pulled.week));
        if (result == null) continue;
        switch (result.list) {
          case null:
            await (_db.delete(
              _db.groceryLists,
            )..where((l) => l.weekStart.equals(pulled.week.key))).go();
          case final list:
            await _write(list, _micros(result.updatedAt));
        }
        // A merge keeps ticks the server doesn't have yet: still pending.
        if (result.sameStateAs(pulled)) await _forgetPending(pulled.week);
      }
      await _db
          .into(_db.syncCursors)
          .insertOnConflictUpdate(
            SyncCursorsCompanion.insert(name: _cursorName, cursor: page.cursor),
          );
    },
  );

  Future<void> _forgetPending(Week week) => (_db.delete(
    _db.pendingGroceryListChanges,
  )..where((c) => c.weekStart.equals(week.key))).go();

  @override
  Future<String?> cursor() async => (await (_db.select(
    _db.syncCursors,
  )..where((c) => c.name.equals(_cursorName))).getSingleOrNull())?.cursor;

  @override
  Future<void> clear() => _db.transaction(() async {
    await _db.delete(_db.pendingGroceryListChanges).go();
    await (_db.delete(
      _db.syncCursors,
    )..where((c) => c.name.equals(_cursorName))).go();
    await _db.delete(_db.groceryLists).go();
  });

  static int _micros(DateTime time) => time.toUtc().microsecondsSinceEpoch;

  static DateTime _time(int micros) =>
      DateTime.fromMicrosecondsSinceEpoch(micros, isUtc: true);

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
          listQuery.where((l) => l.weekStart.equals(week.key));
        }
        if (from != null) {
          listQuery.where((l) => l.weekStart.isBiggerOrEqualValue(from.key));
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
                  id: GroceryItemId(row.uuid),
                  ticked: row.ticked,
                  tickedAt: switch (row.tickedAt) {
                    null => null,
                    final at => _time(at),
                  },
                ),
              );
        }

        return [
          for (final row in lists)
            GroceryList(
              id: GroceryListId(row.uuid),
              week: Week.fromKey(row.weekStart),
              recipes: recipesByList[row.id] ?? const [],
              items: itemsByList[row.id] ?? const [],
            ),
        ];
      });
}
