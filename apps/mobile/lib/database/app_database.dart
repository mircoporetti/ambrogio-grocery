import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

part 'app_database.g.dart';

@DataClassName('RecipeRow')
class Recipes extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get uuid => text().unique()();
  TextColumn get title => text()();
  IntColumn get portions => integer()();
  TextColumn get procedure => text().nullable()();
  TextColumn get photoPath => text().nullable()();
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
  // The Monday as yyyy-MM-dd, so the week doesn't depend on the time zone.
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
}

@DriftDatabase(
  tables: [
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
  int get schemaVersion => 4;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onUpgrade: (m, from, to) async {
      if (from < 2) {
        await m.alterTable(
          TableMigration(
            recipes,
            newColumns: [recipes.uuid],
            columnTransformer: {
              recipes.uuid: const CustomExpression<String>(
                "lower(hex(randomblob(4))) || '-' || lower(hex(randomblob(2)))"
                " || '-4' || substr(lower(hex(randomblob(2))), 2) || '-'"
                " || substr('89ab', 1 + (abs(random()) % 4), 1)"
                " || substr(lower(hex(randomblob(2))), 2) || '-'"
                ' || lower(hex(randomblob(6)))',
              ),
            },
          ),
        );
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
    },
    beforeOpen: (_) => customStatement('PRAGMA foreign_keys = ON'),
  );
}
