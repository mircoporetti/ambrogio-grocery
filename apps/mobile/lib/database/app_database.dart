import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

part 'app_database.g.dart';

@DataClassName('PhotoRow')
class Photos extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get uuid => text().unique()();
  TextColumn get path => text()();
}

@DataClassName('RecipeRow')
class Recipes extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get uuid => text().unique()();
  TextColumn get title => text()();
  IntColumn get portions => integer()();
  TextColumn get procedure => text().nullable()();
  TextColumn get photoId => text().nullable().references(Photos, #uuid)();
}

@DataClassName('IngredientRow')
class RecipeIngredients extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get recipeId =>
      integer().references(Recipes, #id, onDelete: KeyAction.cascade)();
  IntColumn get position => integer()();
  TextColumn get name => text()();
  RealColumn get quantity => real()();
  TextColumn get unit => text()();
}

@DataClassName('CategoryRow')
class RecipeCategories extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get recipeId =>
      integer().references(Recipes, #id, onDelete: KeyAction.cascade)();
  IntColumn get position => integer()();
  TextColumn get name => text()();
}

@DataClassName('GroceryListRow')
class GroceryLists extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get uuid => text().unique()();
  TextColumn get weekStart => text().unique()();
}

@DataClassName('GroceryListRecipeRow')
class GroceryListRecipes extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get listId =>
      integer().references(GroceryLists, #id, onDelete: KeyAction.cascade)();
  IntColumn get position => integer()();
  TextColumn get title => text()();
}

@DataClassName('GroceryListItemRow')
class GroceryListItems extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get listId =>
      integer().references(GroceryLists, #id, onDelete: KeyAction.cascade)();
  IntColumn get position => integer()();
  TextColumn get name => text()();
  RealColumn get quantity => real()();
  TextColumn get unit => text()();
  BoolColumn get ticked => boolean().withDefault(const Constant(false))();
}

const _randomUuid =
    "lower(hex(randomblob(4))) || '-' || lower(hex(randomblob(2)))"
    " || '-4' || substr(lower(hex(randomblob(2))), 2) || '-'"
    " || substr('89ab', 1 + (abs(random()) % 4), 1)"
    " || substr(lower(hex(randomblob(2))), 2) || '-'"
    ' || lower(hex(randomblob(6)))';

@DriftDatabase(
  tables: [
    Photos,
    Recipes,
    RecipeIngredients,
    RecipeCategories,
    GroceryLists,
    GroceryListRecipes,
    GroceryListItems,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase(super.executor);

  AppDatabase.onDevice() : super(driftDatabase(name: 'ambrogio_grocery'));

  @override
  int get schemaVersion => 6;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onUpgrade: (m, from, to) async {
      if (from < 2) {
        await customStatement(
          'CREATE TABLE "recipes_v2" ("id" INTEGER NOT NULL PRIMARY KEY '
          'AUTOINCREMENT, "uuid" TEXT NOT NULL UNIQUE, "title" TEXT NOT NULL, '
          '"portions" INTEGER NOT NULL, "procedure" TEXT NULL, '
          '"photo_path" TEXT NULL)',
        );
        await customStatement(
          'INSERT INTO recipes_v2 '
          '(id, uuid, title, portions, procedure, photo_path) '
          'SELECT id, $_randomUuid, title, portions, procedure, photo_path '
          'FROM recipes',
        );
        await customStatement('DROP TABLE recipes');
        await customStatement('ALTER TABLE recipes_v2 RENAME TO recipes');
      }
      if (from < 3) {
        await customStatement(
          "UPDATE recipes SET photo_path = substr(photo_path, "
          "instr(photo_path, '/photos/') + 1) "
          "WHERE instr(photo_path, '/photos/') > 0",
        );
      }
      if (from < 4) {
        await m.createTable(groceryLists);
        await m.createTable(groceryListRecipes);
        await m.createTable(groceryListItems);
      }
      if (from == 4) {
        await m.addColumn(groceryListItems, groceryListItems.ticked);
      }
      if (from < 6) {
        await m.createTable(photos);
        await m.addColumn(recipes, recipes.photoId);
        await customStatement(
          'UPDATE recipes SET photo_id = $_randomUuid '
          'WHERE photo_path IS NOT NULL',
        );
        await customStatement(
          'INSERT INTO photos (uuid, path) '
          'SELECT photo_id, photo_path FROM recipes WHERE photo_id IS NOT NULL',
        );
        await customStatement('ALTER TABLE recipes DROP COLUMN photo_path');
      }
    },
    beforeOpen: (_) => customStatement('PRAGMA foreign_keys = ON'),
  );
}
