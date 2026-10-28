import 'package:drift/drift.dart';
import 'package:drift_postgres/drift_postgres.dart';

import '../../accounts/domain/account_id.dart';
import '../../database/backend_database.dart';
import '../domain/ingredient.dart';
import '../../photos/domain/photo_id.dart';
import '../domain/recipe.dart';
import '../domain/recipe_change.dart';
import '../domain/recipe_id.dart';
import '../domain/recipe_storage_port.dart';

class DriftRecipeStorageAdapter implements RecipeStoragePort {
  DriftRecipeStorageAdapter(this._db);

  final BackendDatabase _db;

  @override
  Future<Set<PhotoId>> apply(AccountId account, List<RecipeChange> changes) {
    final accountId = UuidValue.fromString(account.value);
    return _db.transaction(() async {
      await _db
          .customSelect(
            r'SELECT id FROM accounts WHERE id = $1 FOR UPDATE',
            variables: [Variable(accountId, PgTypes.uuid)],
          )
          .get();
      final latest = _db.recipes.changeCursor.max();
      var cursor =
          await (_db.selectOnly(_db.recipes)
                ..addColumns([latest])
                ..where(_db.recipes.accountId.equals(accountId)))
              .map((row) => row.read(latest))
              .getSingle() ??
          0;
      final previousPhotos = await _photoIds(
        accountId,
        'id = ANY(\$2::uuid[])',
        [for (final change in changes) change.id.value],
      );

      for (final change in changes) {
        cursor++;
        await _db
            .into(_db.recipes)
            .insert(
              RecipesCompanion.insert(
                accountId: accountId,
                id: UuidValue.fromString(change.id.value),
                updatedAt: PgDateTime(change.updatedAt),
                recipe: Value(_toJson(change.recipe)),
                changeCursor: cursor,
              ),
              onConflict: DoUpdate.withExcluded(
                (old, excluded) => RecipesCompanion.custom(
                  updatedAt: excluded.updatedAt,
                  recipe: excluded.recipe,
                  changeCursor: excluded.changeCursor,
                ),
                where: (old, excluded) =>
                    old.updatedAt.isSmallerThan(excluded.updatedAt),
              ),
            );
      }
      return previousPhotos;
    });
  }

  @override
  Future<Set<PhotoId>> photosInUse(AccountId account, Set<PhotoId> photos) =>
      _photoIds(
        UuidValue.fromString(account.value),
        "recipe->>'photoId' = ANY(\$2::text[])",
        [for (final photo in photos) photo.value],
      );

  Future<Set<PhotoId>> _photoIds(
    UuidValue accountId,
    String condition,
    List<String> values,
  ) async {
    final rows = await _db
        .customSelect(
          "SELECT DISTINCT recipe->>'photoId' AS photo_id FROM recipes "
          r"WHERE account_id = $1 AND recipe->>'photoId' IS NOT NULL "
          'AND $condition',
          variables: [
            Variable(accountId, PgTypes.uuid),
            Variable(values, PgTypes.textArray),
          ],
        )
        .get();
    return {for (final row in rows) PhotoId(row.read<String>('photo_id'))};
  }

  @override
  Future<RecipeChangesPage> changesAfter(
    AccountId account,
    int cursor, {
    required int limit,
  }) async {
    final rows =
        await (_db.select(_db.recipes)
              ..where(
                (r) =>
                    r.accountId.equals(UuidValue.fromString(account.value)) &
                    r.changeCursor.isBiggerThanValue(cursor),
              )
              ..orderBy([(r) => OrderingTerm.asc(r.changeCursor)])
              ..limit(limit + 1))
            .get();
    final page = rows.take(limit).toList();
    return RecipeChangesPage(
      changes: [for (final row in page) _toChange(row)],
      cursor: page.isEmpty ? cursor : page.last.changeCursor,
      hasMore: rows.length > limit,
    );
  }

  RecipeChange _toChange(RecipeRow row) => RecipeChange(
    id: RecipeId(row.id.uuid),
    updatedAt: row.updatedAt.dateTime,
    recipe: row.recipe == null
        ? null
        : _fromJson(row.recipe! as Map<String, Object?>),
  );

  Object? _toJson(Recipe? recipe) => recipe == null
      ? null
      : {
          'title': recipe.title,
          'portions': recipe.portions,
          'procedure': recipe.procedure,
          'photoId': recipe.photoId?.value,
          'categories': recipe.categories,
          'ingredients': [
            for (final i in recipe.ingredients)
              {'name': i.name, 'quantity': i.quantity, 'unit': i.unit.symbol},
          ],
        };

  Recipe _fromJson(Map<String, Object?> json) => Recipe(
    title: json['title']! as String,
    portions: json['portions']! as int,
    procedure: json['procedure'] as String?,
    photoId: switch (json['photoId']) {
      final String id => PhotoId(id),
      _ => null,
    },
    categories: (json['categories']! as List).cast<String>(),
    ingredients: [
      for (final i in (json['ingredients']! as List).cast<Map>())
        Ingredient(
          name: i['name'] as String,
          quantity: (i['quantity'] as num).toDouble(),
          unit: MeasureUnit.fromSymbol(i['unit'] as String)!,
        ),
    ],
  );
}
