import 'package:drift/drift.dart';
import 'package:path/path.dart' as p;

import '../../database/app_database.dart';
import '../domain/ingredient.dart';
import '../domain/photo.dart';
import '../domain/photo_id.dart';
import '../domain/recipe.dart';
import '../domain/recipe_id.dart';
import '../domain/recipe_storage_port.dart';

class DriftRecipeStorageAdapter implements RecipeStoragePort {
  DriftRecipeStorageAdapter(this._db, {required String documentsDir})
    : _documentsDir = documentsDir;

  final AppDatabase _db;

  final String _documentsDir;

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
    final photo = recipe.photo;
    if (photo != null) {
      await _db
          .into(_db.photos)
          .insert(
            PhotosCompanion.insert(
              uuid: photo.id.value,
              path: _toStored(photo.path)!,
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
    await _deleteUnusedPhotos();
  });

  @override
  Future<void> delete(RecipeId id) => _db.transaction(() async {
    await (_db.delete(_db.recipes)..where((r) => r.uuid.equals(id.value))).go();
    await _deleteUnusedPhotos();
  });

  Future<void> _deleteUnusedPhotos() => _db.customStatement(
    'DELETE FROM photos WHERE uuid NOT IN '
    '(SELECT photo_id FROM recipes WHERE photo_id IS NOT NULL)',
  );

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
  Stream<Recipe?> watchById(RecipeId id) =>
      _changes().asyncMap((_) async => (await _load(id: id)).firstOrNull);

  @override
  Future<List<Recipe>> findAll() => _load();

  @override
  Future<Recipe?> findById(RecipeId id) async =>
      (await _load(id: id)).firstOrNull;

  Future<List<Recipe>> _load({RecipeId? id}) => _db.transaction(() async {
    final recipeQuery = _db.select(_db.recipes)
      ..orderBy([(r) => OrderingTerm.asc(r.id)]);
    if (id != null) recipeQuery.where((r) => r.uuid.equals(id.value));
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
        row.uuid: Photo(id: PhotoId(row.uuid), path: _fromStored(row.path)!),
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
