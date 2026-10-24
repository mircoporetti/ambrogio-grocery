import 'package:drift/drift.dart';

import '../../database/app_database.dart';
import '../domain/ingredient.dart';
import '../domain/recipe.dart';
import '../domain/recipe_storage_port.dart';

class DriftRecipeStorageAdapter implements RecipeStoragePort {
  DriftRecipeStorageAdapter(this._db);

  final AppDatabase _db;

  @override
  Future<void> save(Recipe recipe) => _db.transaction(() async {
    final recipeId = await _db
        .into(_db.recipes)
        .insert(
          RecipesCompanion.insert(
            title: recipe.title,
            portions: recipe.portions,
            procedure: Value(recipe.procedure),
            photoPath: Value(recipe.photoPath),
          ),
        );
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
  });

  /// Re-reads every recipe whenever any of the three tables changes. drift
  /// only notifies after a transaction commits, so a recipe is never seen
  /// without its ingredients.
  @override
  Stream<List<Recipe>> watchAll() => _db
      .customSelect(
        'SELECT 1',
        readsFrom: {_db.recipes, _db.recipeIngredients, _db.recipeCategories},
      )
      .watch()
      .asyncMap((_) => findAll());

  @override
  Future<List<Recipe>> findAll() => _db.transaction(() async {
    final recipes = await (_db.select(
      _db.recipes,
    )..orderBy([(r) => OrderingTerm.asc(r.id)])).get();
    final ingredients = await (_db.select(
      _db.recipeIngredients,
    )..orderBy([(i) => OrderingTerm.asc(i.position)])).get();
    final categories = await (_db.select(
      _db.recipeCategories,
    )..orderBy([(c) => OrderingTerm.asc(c.position)])).get();

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
    final categoriesByRecipe = <int, List<String>>{};
    for (final row in categories) {
      categoriesByRecipe.putIfAbsent(row.recipeId, () => []).add(row.name);
    }

    return [
      for (final row in recipes)
        Recipe(
          title: row.title,
          portions: row.portions,
          ingredients: ingredientsByRecipe[row.id] ?? const [],
          procedure: row.procedure,
          photoPath: row.photoPath,
          categories: categoriesByRecipe[row.id] ?? const [],
        ),
    ];
  });
}
