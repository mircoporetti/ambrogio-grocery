import 'dart:math';

import 'package:drift/drift.dart';
import 'package:path/path.dart' as p;

import '../../database/app_database.dart';
import '../domain/ingredient.dart';
import '../domain/photo.dart';
import '../domain/photo_id.dart';
import '../domain/recipe.dart';
import '../domain/recipe_change.dart';
import '../domain/recipe_id.dart';
import '../domain/recipe_storage_port.dart';
import '../domain/recipe_sync_storage_port.dart';

class DriftRecipeStorageAdapter
    implements RecipeStoragePort, RecipeSyncStoragePort {
  DriftRecipeStorageAdapter(this._db, {required String documentsDir})
    : _documentsDir = documentsDir;

  final AppDatabase _db;

  final String _documentsDir;

  static const _cursorName = 'recipes';

  String? _toStored(String? path) {
    if (path == null || !p.isWithin(_documentsDir, path)) return path;
    return p.relative(path, from: _documentsDir);
  }

  String? _fromStored(String? path) {
    if (path == null || p.isAbsolute(path)) return path;
    return p.join(_documentsDir, path);
  }

  @override
  Future<void> save(Recipe recipe) => _db.transaction(() async {
    final updatedAt = await _nextUpdatedAt(recipe.id);
    await _write(recipe, updatedAt);
    await _markPending(recipe.id, updatedAt);
    await _deleteUnusedPhotos();
  });

  @override
  Future<void> delete(RecipeId id) => _db.transaction(() async {
    final updatedAt = await _nextUpdatedAt(id);
    await (_db.delete(_db.recipes)..where((r) => r.uuid.equals(id.value))).go();
    await _markPending(id, updatedAt);
    await _deleteUnusedPhotos();
  });

  /// Never before the last change: another phone's clock may run ahead.
  Future<int> _nextUpdatedAt(RecipeId id) async {
    final now = DateTime.now().toUtc().microsecondsSinceEpoch;
    final last = await _localUpdatedAt(id.value);
    return last == null ? now : max(now, last + 1);
  }

  Future<int?> _localUpdatedAt(String uuid) async {
    final recipe = await (_db.select(
      _db.recipes,
    )..where((r) => r.uuid.equals(uuid))).getSingleOrNull();
    final pending = await (_db.select(
      _db.pendingRecipeChanges,
    )..where((c) => c.recipeUuid.equals(uuid))).getSingleOrNull();
    return [?recipe?.updatedAt, ?pending?.updatedAt].fold<int?>(
      null,
      (latest, time) => latest == null ? time : max(latest, time),
    );
  }

  Future<void> _markPending(RecipeId id, int updatedAt) => _db
      .into(_db.pendingRecipeChanges)
      .insertOnConflictUpdate(
        PendingRecipeChangesCompanion.insert(
          recipeUuid: id.value,
          updatedAt: updatedAt,
        ),
      );

  Future<void> _write(Recipe recipe, int updatedAt) async {
    final photo = recipe.photo;
    if (photo != null) {
      // A synced photo has no path; keep the file if this phone has it.
      await _db
          .into(_db.photos)
          .insert(
            PhotosCompanion.insert(
              uuid: photo.id.value,
              path: Value(_toStored(photo.path)),
              uploaded: Value(photo.path == null),
            ),
            mode: InsertMode.insertOrIgnore,
          );
    }
    final row = RecipesCompanion.insert(
      uuid: recipe.id.value,
      title: recipe.title,
      portions: recipe.portions,
      procedure: Value(recipe.procedure),
      photoId: Value(photo?.id.value),
      updatedAt: Value(updatedAt),
    );
    final existing = await (_db.select(
      _db.recipes,
    )..where((r) => r.uuid.equals(recipe.id.value))).getSingleOrNull();

    final int recipeId;
    if (existing == null) {
      recipeId = await _db.into(_db.recipes).insert(row);
    } else {
      recipeId = existing.id;
      await (_db.update(
        _db.recipes,
      )..where((r) => r.id.equals(recipeId))).write(row);
      await (_db.delete(
        _db.recipeIngredients,
      )..where((i) => i.recipeId.equals(recipeId))).go();
      await (_db.delete(
        _db.recipeCategories,
      )..where((c) => c.recipeId.equals(recipeId))).go();
    }
    await _db.batch((batch) {
      batch.insertAll(_db.recipeIngredients, [
        for (final (position, ingredient) in recipe.ingredients.indexed)
          RecipeIngredientsCompanion.insert(
            recipeId: recipeId,
            position: position,
            name: ingredient.name,
            quantity: ingredient.quantity,
            unit: ingredient.unit.name,
          ),
      ]);
      batch.insertAll(_db.recipeCategories, [
        for (final (position, category) in recipe.categories.indexed)
          RecipeCategoriesCompanion.insert(
            recipeId: recipeId,
            position: position,
            name: category,
          ),
      ]);
    });
  }

  Future<List<Photo>> _deleteUnusedPhotos() async {
    final unused = _db.photos.uuid.isNotInQuery(
      _db.selectOnly(_db.recipes)
        ..addColumns([_db.recipes.photoId])
        ..where(_db.recipes.photoId.isNotNull()),
    );
    final rows = await (_db.select(_db.photos)..where((_) => unused)).get();
    await (_db.delete(_db.photos)..where((_) => unused)).go();
    return [
      for (final row in rows)
        Photo(id: PhotoId(row.uuid), path: _fromStored(row.path)),
    ];
  }

  @override
  Future<List<RecipeChange>> pendingChanges() => _db.transaction(() async {
    final pending = await (_db.select(
      _db.pendingRecipeChanges,
    )..orderBy([(c) => OrderingTerm.asc(c.updatedAt)])).get();
    if (pending.isEmpty) return const <RecipeChange>[];
    final recipes = {
      for (final recipe in await _load(
        uuids: [for (final c in pending) c.recipeUuid],
      ))
        recipe.id.value: recipe,
    };
    return [
      for (final change in pending)
        RecipeChange(
          id: RecipeId(change.recipeUuid),
          updatedAt: _time(change.updatedAt),
          recipe: recipes[change.recipeUuid],
        ),
    ];
  });

  @override
  Stream<int> watchPendingCount() {
    final count = countAll();
    return (_db.selectOnly(
      _db.pendingRecipeChanges,
    )..addColumns([count])).map((row) => row.read(count)!).watchSingle();
  }

  @override
  Future<void> markPushed(List<RecipeChange> changes) =>
      _db.transaction(() async {
        for (final change in changes) {
          await (_db.delete(_db.pendingRecipeChanges)..where(
                (c) =>
                    c.recipeUuid.equals(change.id.value) &
                    c.updatedAt.equals(_micros(change.updatedAt)),
              ))
              .go();
        }
      });

  @override
  Future<List<Photo>> photosToUpload() async => [
    for (final row in await (_db.select(
      _db.photos,
    )..where((p) => p.uploaded.not() & p.path.isNotNull())).get())
      Photo(id: PhotoId(row.uuid), path: _fromStored(row.path)),
  ];

  @override
  Future<void> stopUploadingPhoto(PhotoId id) =>
      (_db.update(_db.photos)..where((p) => p.uuid.equals(id.value))).write(
        const PhotosCompanion(uploaded: Value(true)),
      );

  @override
  Future<List<PhotoId>> photosToDownload() async => [
    for (final row in await (_db.select(
      _db.photos,
    )..where((p) => p.path.isNull())).get())
      PhotoId(row.uuid),
  ];

  @override
  Future<bool> savePhotoPath(PhotoId id, String path) async {
    final updated =
        await (_db.update(_db.photos)
              ..where((p) => p.uuid.equals(id.value) & p.path.isNull()))
            .write(PhotosCompanion(path: Value(_toStored(path))));
    return updated > 0;
  }

  @override
  Future<List<Photo>> applyPulled(RecipeChangesPage page) => _db.transaction(
    () async {
      for (final change in page.changes) {
        final updatedAt = _micros(change.updatedAt);
        final local = await _localUpdatedAt(change.id.value);
        if (local != null && updatedAt <= local) continue;
        switch (change.recipe) {
          case null:
            await (_db.delete(
              _db.recipes,
            )..where((r) => r.uuid.equals(change.id.value))).go();
          case final recipe:
            await _write(recipe, updatedAt);
        }
        await (_db.delete(
          _db.pendingRecipeChanges,
        )..where((c) => c.recipeUuid.equals(change.id.value))).go();
      }
      final removed = await _deleteUnusedPhotos();
      await _db
          .into(_db.syncCursors)
          .insertOnConflictUpdate(
            SyncCursorsCompanion.insert(name: _cursorName, cursor: page.cursor),
          );
      return removed;
    },
  );

  @override
  Future<String?> cursor() async => (await (_db.select(
    _db.syncCursors,
  )..where((c) => c.name.equals(_cursorName))).getSingleOrNull())?.cursor;

  @override
  Future<void> clear() => _db.transaction(() async {
    await _db.delete(_db.pendingRecipeChanges).go();
    await (_db.delete(
      _db.syncCursors,
    )..where((c) => c.name.equals(_cursorName))).go();
    await _db.delete(_db.recipes).go();
    await _db.delete(_db.photos).go();
  });

  static int _micros(DateTime time) => time.toUtc().microsecondsSinceEpoch;

  static DateTime _time(int micros) =>
      DateTime.fromMicrosecondsSinceEpoch(micros, isUtc: true);

  Stream<void> _changes() => _db
      .customSelect(
        'SELECT 1',
        readsFrom: {
          _db.recipes,
          _db.recipeIngredients,
          _db.recipeCategories,
          _db.photos,
        },
      )
      .watch();

  @override
  Stream<List<Recipe>> watchAll() => _changes().asyncMap((_) => findAll());

  @override
  Stream<Recipe?> watchById(RecipeId id) => _changes().asyncMap(
    (_) async => (await _load(uuids: [id.value])).firstOrNull,
  );

  @override
  Future<List<Recipe>> findAll() => _load();

  @override
  Future<Recipe?> findById(RecipeId id) async =>
      (await _load(uuids: [id.value])).firstOrNull;

  Future<List<Recipe>> _load({List<String>? uuids}) =>
      _db.transaction(() async {
        final recipeQuery = _db.select(_db.recipes)
          ..orderBy([(r) => OrderingTerm.asc(r.id)]);
        if (uuids != null) recipeQuery.where((r) => r.uuid.isIn(uuids));
        final recipes = await recipeQuery.get();
        if (recipes.isEmpty) return const <Recipe>[];

        final rowIds = recipes.map((r) => r.id).toList();
        final ingredients =
            await (_db.select(_db.recipeIngredients)
                  ..where((i) => i.recipeId.isIn(rowIds))
                  ..orderBy([(i) => OrderingTerm.asc(i.position)]))
                .get();
        final categories =
            await (_db.select(_db.recipeCategories)
                  ..where((c) => c.recipeId.isIn(rowIds))
                  ..orderBy([(c) => OrderingTerm.asc(c.position)]))
                .get();

        final ingredientsByRecipe = <int, List<Ingredient>>{};
        for (final row in ingredients) {
          ingredientsByRecipe
              .putIfAbsent(row.recipeId, () => [])
              .add(
                Ingredient(
                  name: row.name,
                  quantity: row.quantity,
                  unit: MeasureUnit.values.byName(row.unit),
                ),
              );
        }
        final photoIds = [for (final row in recipes) ?row.photoId];
        final photos = {
          for (final row in await (_db.select(
            _db.photos,
          )..where((p) => p.uuid.isIn(photoIds))).get())
            row.uuid: Photo(id: PhotoId(row.uuid), path: _fromStored(row.path)),
        };
        final categoriesByRecipe = <int, List<String>>{};
        for (final row in categories) {
          categoriesByRecipe.putIfAbsent(row.recipeId, () => []).add(row.name);
        }

        return [
          for (final row in recipes)
            Recipe(
              id: RecipeId(row.uuid),
              title: row.title,
              portions: row.portions,
              ingredients: ingredientsByRecipe[row.id] ?? const [],
              procedure: row.procedure,
              photo: photos[row.photoId],
              categories: categoriesByRecipe[row.id] ?? const [],
            ),
        ];
      });
}
