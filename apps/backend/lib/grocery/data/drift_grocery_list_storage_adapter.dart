import 'package:drift/drift.dart';
import 'package:drift_postgres/drift_postgres.dart';

import '../../accounts/domain/account_id.dart';
import '../../database/backend_database.dart';
import '../domain/grocery_item.dart';
import '../domain/grocery_list.dart';
import '../domain/grocery_list_change.dart';
import '../domain/grocery_list_storage_port.dart';
import '../domain/week.dart';

class DriftGroceryListStorageAdapter implements GroceryListStoragePort {
  DriftGroceryListStorageAdapter(this._db);

  final BackendDatabase _db;

  @override
  Future<void> apply(AccountId account, List<GroceryListChange> changes) {
    final accountId = UuidValue.fromString(account.value);
    return _db.transaction(() async {
      // Serializes the account's pushes, so cursors follow commit order.
      await _db
          .customSelect(
            r'SELECT id FROM accounts WHERE id = $1 FOR UPDATE',
            variables: [Variable(accountId, PgTypes.uuid)],
          )
          .get();
      final latest = _db.groceryLists.changeCursor.max();
      var cursor =
          await (_db.selectOnly(_db.groceryLists)
                ..addColumns([latest])
                ..where(_db.groceryLists.accountId.equals(accountId)))
              .map((row) => row.read(latest))
              .getSingle() ??
          0;

      for (final change in changes) {
        final row =
            await (_db.select(_db.groceryLists)..where(
                  (l) =>
                      l.accountId.equals(accountId) &
                      l.week.equals(change.week.key),
                ))
                .getSingleOrNull();
        final result = change.applyTo(row == null ? null : _toChange(row));
        if (result == null) continue;
        await _db
            .into(_db.groceryLists)
            .insertOnConflictUpdate(
              GroceryListsCompanion.insert(
                accountId: accountId,
                week: result.week.key,
                updatedAt: PgDateTime(result.updatedAt),
                list: Value(_toJson(result.list)),
                changeCursor: ++cursor,
              ),
            );
      }
    });
  }

  @override
  Future<GroceryListChangesPage> changesAfter(
    AccountId account,
    int cursor, {
    required int limit,
  }) async {
    final rows =
        await (_db.select(_db.groceryLists)
              ..where(
                (l) =>
                    l.accountId.equals(UuidValue.fromString(account.value)) &
                    l.changeCursor.isBiggerThanValue(cursor),
              )
              ..orderBy([(l) => OrderingTerm.asc(l.changeCursor)])
              ..limit(limit + 1))
            .get();
    final page = rows.take(limit).toList();
    return GroceryListChangesPage(
      changes: [for (final row in page) _toChange(row)],
      cursor: page.isEmpty ? cursor : page.last.changeCursor,
      hasMore: rows.length > limit,
    );
  }

  GroceryListChange _toChange(GroceryListRow row) => GroceryListChange(
    week: Week.fromKey(row.week),
    updatedAt: row.updatedAt.dateTime,
    list: row.list == null
        ? null
        : _fromJson(row.list! as Map<String, Object?>),
  );

  Object? _toJson(GroceryList? list) => list == null
      ? null
      : {
          'id': list.id,
          'recipes': list.recipes,
          'items': [
            for (final i in list.items)
              {
                'id': i.id,
                'name': i.name,
                'quantity': i.quantity,
                'unit': i.unit.symbol,
                'ticked': i.ticked,
                'tickedAt': i.tickedAt?.toIso8601String(),
              },
          ],
        };

  GroceryList _fromJson(Map<String, Object?> json) => GroceryList(
    id: json['id']! as String,
    recipes: (json['recipes']! as List).cast<String>(),
    items: [
      for (final i in (json['items']! as List).cast<Map>())
        GroceryItem(
          id: i['id'] as String,
          name: i['name'] as String,
          quantity: (i['quantity'] as num).toDouble(),
          unit: MeasureUnit.fromSymbol(i['unit'] as String)!,
          ticked: i['ticked'] as bool,
          tickedAt: switch (i['tickedAt']) {
            final String at => DateTime.parse(at),
            _ => null,
          },
        ),
    ],
  );
}
