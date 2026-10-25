import 'package:ambrogio_grocery/database/app_database.dart';
import 'package:ambrogio_grocery/grocery/data/drift_grocery_list_storage_adapter.dart';
import 'package:ambrogio_grocery/recipes/data/drift_recipe_storage_adapter.dart';
import 'package:ambrogio_grocery/recipes/domain/ingredient.dart';
import 'package:ambrogio_grocery/recipes/domain/recipe.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/failing_grocery_list_storage_adapter.dart';
import 'support/grocery_robot.dart';
import 'support/recipe_robot.dart';
import 'support/test_database.dart';

void main() {
  late AppDatabase db;
  late DriftRecipeStorageAdapter recipes;
  late DriftGroceryListStorageAdapter lists;
  late GroceryRobot robot;

  setUp(() {
    db = openInMemoryDatabase();
    recipes = DriftRecipeStorageAdapter(db, documentsDir: testDocumentsDir);
    lists = DriftGroceryListStorageAdapter(db);
  });

  Ingredient grams(String name, double quantity) =>
      Ingredient(name: name, quantity: quantity, unit: MeasureUnit.grams);

  Future<void> openNewList(
    WidgetTester tester, {
    FailingGroceryListStorageAdapter? failingLists,
  }) async {
    await recipes.save(
      Recipe(
        title: 'Carbonara',
        portions: 2,
        ingredients: [
          grams('Guanciale', 150),
          grams('Pecorino', 50),
          grams('Spaghetti', 320),
        ],
      ),
    );
    await RecipeRobot(
      tester,
    ).launchApp(recipes, groceryListStorage: failingLists ?? lists);
    robot = GroceryRobot(tester);
    await robot.startPlanningWeek();
    await robot.cook();
    await robot.createGroceryList();
  }

  testWidgets('a new list has nothing ticked', (tester) async {
    await openNewList(tester);

    expect(robot.isTicked('Guanciale'), isFalse);
    expect(robot.isTicked('Pecorino'), isFalse);
    expect(robot.isTicked('Spaghetti'), isFalse);
  });

  testWidgets('ticking and unticking keep the list in alphabetical order', (
    tester,
  ) async {
    await openNewList(tester);

    await robot.tick('Guanciale');
    await robot.tick('Pecorino');

    expect(robot.isTicked('Guanciale'), isTrue);
    expect(robot.isTicked('Pecorino'), isTrue);
    expect(robot.groceryList, [
      'Guanciale 150 g',
      'Pecorino 50 g',
      'Spaghetti 320 g',
    ]);

    await robot.untick('Guanciale');

    expect(robot.isTicked('Guanciale'), isFalse);
    expect(robot.groceryList, [
      'Guanciale 150 g',
      'Pecorino 50 g',
      'Spaghetti 320 g',
    ]);
  });

  testWidgets('ticks are kept when the list is opened again', (tester) async {
    await openNewList(tester);
    await robot.tick('Spaghetti');
    await robot.goBack();
    await RecipeRobot(tester).closeApp();

    await RecipeRobot(tester).launchApp(recipes, groceryListStorage: lists);
    await robot.openGroceryLists();
    await robot.openGroceryList('19 – 25 Oct');

    expect(robot.isTicked('Spaghetti'), isTrue);
    expect(robot.isTicked('Guanciale'), isFalse);
  });

  testWidgets('if saving a tick fails, the item stays as it was', (
    tester,
  ) async {
    final failingLists = FailingGroceryListStorageAdapter(lists);
    await openNewList(tester, failingLists: failingLists);
    failingLists.failSaves = true;

    await robot.tick('Guanciale');

    expect(
      find.text('Could not update the grocery list. Please try again.'),
      findsOneWidget,
    );
    expect(robot.isTicked('Guanciale'), isFalse);

    failingLists.failSaves = false;
    await robot.tick('Guanciale');

    expect(robot.isTicked('Guanciale'), isTrue);
    expect(
      find.text('Could not update the grocery list. Please try again.'),
      findsNothing,
    );
  });
}
