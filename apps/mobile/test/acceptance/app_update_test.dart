import 'dart:io';

import 'package:ambrogio_grocery/grocery/data/drift_grocery_list_storage_adapter.dart';
import 'package:ambrogio_grocery/recipes/data/drift_recipe_storage_adapter.dart';
import 'package:ambrogio_grocery/recipes/domain/ingredient.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqlite3/sqlite3.dart';

import 'support/grocery_robot.dart';
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
    final storage = DriftRecipeStorageAdapter(
      db,
      documentsDir: testDocumentsDir,
    );
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

  testWidgets('photos saved with absolute paths survive the update', (
    tester,
  ) async {
    final file = newDatabaseFile();
    _writeVersion2Database(
      file,
      photoPath: '/data/user/0/app/app_flutter/photos/carbonara.jpg',
    );

    final db = openFileDatabase(file);
    addTearDown(db.close);
    final storage = DriftRecipeStorageAdapter(
      db,
      documentsDir: testDocumentsDir,
    );
    final robot = RecipeRobot(tester);
    await robot.launchApp(storage);

    expect(find.text('Carbonara'), findsOneWidget);
    final recipe = (await storage.findAll()).single;
    expect(recipe.photoPath, '$testDocumentsDir/photos/carbonara.jpg');
  });

  testWidgets('after the update, grocery lists can be saved', (tester) async {
    final file = newDatabaseFile();
    _writeVersion3Database(file);

    final db = openFileDatabase(file);
    addTearDown(db.close);
    final lists = DriftGroceryListStorageAdapter(db);
    await RecipeRobot(tester).launchApp(
      DriftRecipeStorageAdapter(db, documentsDir: testDocumentsDir),
      groceryListStorage: lists,
    );
    expect(find.text('Carbonara'), findsOneWidget);

    final robot = GroceryRobot(tester);
    await robot.startPlanningWeek();
    await robot.cook();
    await robot.createGroceryList();

    expect(robot.groceryList, ['Spaghetti 320 g']);
    expect((await lists.findAll()).single.recipes, ['Carbonara']);
  });

  testWidgets('grocery lists saved before ticking survive the update', (
    tester,
  ) async {
    final file = newDatabaseFile();
    _writeVersion4Database(file);

    final db = openFileDatabase(file);
    addTearDown(db.close);
    await RecipeRobot(tester).launchApp(
      DriftRecipeStorageAdapter(db, documentsDir: testDocumentsDir),
      groceryListStorage: DriftGroceryListStorageAdapter(db),
    );

    final robot = GroceryRobot(tester);
    await robot.openGroceryLists();
    await robot.openGroceryList('19 – 25 Oct');
    expect(robot.groceryList, ['Guanciale 150 g', 'Spaghetti 320 g']);
    expect(robot.isTicked('Guanciale'), isFalse);

    await robot.tick('Guanciale');
    expect(robot.isTicked('Guanciale'), isTrue);
  });
}

// Schema version 4 had no ticks on grocery list items.
void _writeVersion4Database(File file) {
  final raw = sqlite3.open(file.path);
  raw.execute('''
    CREATE TABLE "recipes" ("id" INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT, "uuid" TEXT NOT NULL UNIQUE, "title" TEXT NOT NULL, "portions" INTEGER NOT NULL, "procedure" TEXT NULL, "photo_path" TEXT NULL);
    CREATE TABLE "recipe_ingredients" ("id" INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT, "recipe_id" INTEGER NOT NULL REFERENCES recipes (id) ON DELETE CASCADE, "position" INTEGER NOT NULL, "name" TEXT NOT NULL, "quantity" REAL NOT NULL, "unit" TEXT NOT NULL);
    CREATE TABLE "recipe_categories" ("id" INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT, "recipe_id" INTEGER NOT NULL REFERENCES recipes (id) ON DELETE CASCADE, "position" INTEGER NOT NULL, "name" TEXT NOT NULL);
    CREATE TABLE "grocery_lists" ("id" INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT, "uuid" TEXT NOT NULL UNIQUE, "week_start" TEXT NOT NULL UNIQUE);
    CREATE TABLE "grocery_list_recipes" ("id" INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT, "list_id" INTEGER NOT NULL REFERENCES grocery_lists (id) ON DELETE CASCADE, "position" INTEGER NOT NULL, "title" TEXT NOT NULL);
    CREATE TABLE "grocery_list_items" ("id" INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT, "list_id" INTEGER NOT NULL REFERENCES grocery_lists (id) ON DELETE CASCADE, "position" INTEGER NOT NULL, "name" TEXT NOT NULL, "quantity" REAL NOT NULL, "unit" TEXT NOT NULL);
    INSERT INTO grocery_lists (uuid, week_start) VALUES ('7c1e2d3f-4a5b-4c6d-8e7f-9a0b1c2d3e4f', '2026-10-19');
    INSERT INTO grocery_list_recipes (list_id, position, title) VALUES (1, 0, 'Carbonara');
    INSERT INTO grocery_list_items (list_id, position, name, quantity, unit) VALUES (1, 0, 'Guanciale', 150, 'grams');
    INSERT INTO grocery_list_items (list_id, position, name, quantity, unit) VALUES (1, 1, 'Spaghetti', 320, 'grams');
    PRAGMA user_version = 4;
  ''');
  raw.close();
}

// Schema version 3 had no grocery lists.
void _writeVersion3Database(File file) {
  final raw = sqlite3.open(file.path);
  raw.execute('''
    CREATE TABLE "recipes" ("id" INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT, "uuid" TEXT NOT NULL UNIQUE, "title" TEXT NOT NULL, "portions" INTEGER NOT NULL, "procedure" TEXT NULL, "photo_path" TEXT NULL);
    CREATE TABLE "recipe_ingredients" ("id" INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT, "recipe_id" INTEGER NOT NULL REFERENCES recipes (id) ON DELETE CASCADE, "position" INTEGER NOT NULL, "name" TEXT NOT NULL, "quantity" REAL NOT NULL, "unit" TEXT NOT NULL);
    CREATE TABLE "recipe_categories" ("id" INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT, "recipe_id" INTEGER NOT NULL REFERENCES recipes (id) ON DELETE CASCADE, "position" INTEGER NOT NULL, "name" TEXT NOT NULL);
    INSERT INTO recipes (uuid, title, portions) VALUES ('4b6f1c2e-8a3d-4f5b-9c7e-1d2a3b4c5d6e', 'Carbonara', 4);
    INSERT INTO recipe_ingredients (recipe_id, position, name, quantity, unit) VALUES (1, 0, 'Spaghetti', 320, 'grams');
    PRAGMA user_version = 3;
  ''');
  raw.close();
}

// Schema version 2 stored the photo's absolute path.
void _writeVersion2Database(File file, {required String photoPath}) {
  final raw = sqlite3.open(file.path);
  raw.execute('''
    CREATE TABLE "recipes" ("id" INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT, "uuid" TEXT NOT NULL UNIQUE, "title" TEXT NOT NULL, "portions" INTEGER NOT NULL, "procedure" TEXT NULL, "photo_path" TEXT NULL);
    CREATE TABLE "recipe_ingredients" ("id" INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT, "recipe_id" INTEGER NOT NULL REFERENCES recipes (id) ON DELETE CASCADE, "position" INTEGER NOT NULL, "name" TEXT NOT NULL, "quantity" REAL NOT NULL, "unit" TEXT NOT NULL);
    CREATE TABLE "recipe_categories" ("id" INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT, "recipe_id" INTEGER NOT NULL REFERENCES recipes (id) ON DELETE CASCADE, "position" INTEGER NOT NULL, "name" TEXT NOT NULL);
    INSERT INTO recipes (uuid, title, portions, photo_path) VALUES ('4b6f1c2e-8a3d-4f5b-9c7e-1d2a3b4c5d6e', 'Carbonara', 4, '$photoPath');
    INSERT INTO recipe_ingredients (recipe_id, position, name, quantity, unit) VALUES (1, 0, 'Spaghetti', 320, 'grams');
    PRAGMA user_version = 2;
  ''');
  raw.close();
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
