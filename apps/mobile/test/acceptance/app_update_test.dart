import 'dart:io';

import 'package:ambrogio_grocery/recipes/data/drift_recipe_storage_adapter.dart';
import 'package:ambrogio_grocery/recipes/domain/ingredient.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqlite3/sqlite3.dart';

import 'support/recipe_robot.dart';
import 'support/test_database.dart';

void main() {
  testWidgets('recipes saved by the first app version survive the update', (
    tester,
  ) async {
    final file = newDatabaseFile();
    _writeVersion1Database(file);

    final db = openFileDatabase(file);
    addTearDown(db.close);
    final storage = DriftRecipeStorageAdapter(db);
    final robot = RecipeRobot(tester);
    await robot.launchApp(storage);

    expect(find.text('Carbonara'), findsOneWidget);
    expect(find.text('4 portions · Pasta'), findsOneWidget);
    await robot.openRecipe('Carbonara');
    expect(find.text('320 g'), findsOneWidget);

    final recipe = (await storage.findAll()).single;
    expect(recipe.ingredients, [
      Ingredient(name: 'Spaghetti', quantity: 320, unit: MeasureUnit.grams),
    ]);
    expect(recipe.procedure, 'Boil the pasta.');
  });
}

// Exactly what schema version 1 created on devices, frozen here on purpose:
// it must not change when the app's tables do.
void _writeVersion1Database(File file) {
  final raw = sqlite3.open(file.path);
  raw.execute('''
    CREATE TABLE "recipes" ("id" INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT, "title" TEXT NOT NULL, "portions" INTEGER NOT NULL, "procedure" TEXT NULL, "photo_path" TEXT NULL);
    CREATE TABLE "recipe_ingredients" ("id" INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT, "recipe_id" INTEGER NOT NULL REFERENCES recipes (id) ON DELETE CASCADE, "position" INTEGER NOT NULL, "name" TEXT NOT NULL, "quantity" REAL NOT NULL, "unit" TEXT NOT NULL);
    CREATE TABLE "recipe_categories" ("id" INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT, "recipe_id" INTEGER NOT NULL REFERENCES recipes (id) ON DELETE CASCADE, "position" INTEGER NOT NULL, "name" TEXT NOT NULL);
    INSERT INTO recipes (title, portions, procedure) VALUES ('Carbonara', 4, 'Boil the pasta.');
    INSERT INTO recipe_ingredients (recipe_id, position, name, quantity, unit) VALUES (1, 0, 'Spaghetti', 320, 'grams');
    INSERT INTO recipe_categories (recipe_id, position, name) VALUES (1, 0, 'Pasta');
    PRAGMA user_version = 1;
  ''');
  raw.close();
}
