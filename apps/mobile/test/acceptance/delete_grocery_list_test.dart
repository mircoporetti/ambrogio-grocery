import 'package:ambrogio_grocery/database/app_database.dart';
import 'package:ambrogio_grocery/grocery/data/drift_grocery_list_storage_adapter.dart';
import 'package:ambrogio_grocery/recipes/data/drift_recipe_storage_adapter.dart';
import 'package:ambrogio_grocery/recipes/domain/ingredient.dart';
import 'package:ambrogio_grocery/recipes/domain/recipe.dart';
import 'package:flutter/foundation.dart';
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

  Future<void> launchWithTwoLists(
    WidgetTester tester, {
    FailingGroceryListStorageAdapter? failingLists,
  }) async {
    await recipes.save(
      Recipe(
        title: 'Carbonara',
        portions: 2,
        ingredients: [
          Ingredient(name: 'Spaghetti', quantity: 320, unit: MeasureUnit.grams),
        ],
      ),
    );
    await RecipeRobot(
      tester,
    ).launchApp(recipes, groceryListStorage: failingLists ?? lists);
    robot = GroceryRobot(tester);
    await robot.openGroceryLists();
    for (final laterWeeks in [0, 1]) {
      await robot.planWeek();
      for (var i = 0; i < laterWeeks; i++) {
        await robot.laterWeek();
      }
      await robot.cook();
      await robot.createGroceryList();
      await robot.goBack();
    }
  }

  testWidgets('a deleted grocery list disappears from the lists', (
    tester,
  ) async {
    await launchWithTwoLists(tester);

    await robot.openGroceryList('19 – 25 Oct');
    await robot.deleteOpenGroceryList();
    expect(find.text('Delete the list for 19 – 25 Oct?'), findsOneWidget);
    await robot.confirmDelete();

    expect(find.text('Grocery lists'), findsOneWidget);
    expect(robot.groceryListWeeks, ['26 Oct – 1 Nov']);
    final weeks = (await lists.findAll()).map((l) => l.week.start);
    expect(weeks, [DateTime(2026, 10, 26)]);
  });

  testWidgets(
    'with a mouse a grocery list is deleted with its button in the list',
    (tester) async {
      await launchWithTwoLists(tester);

      await robot.deleteFromList('19 – 25 Oct');
      expect(find.text('Delete the list for 19 – 25 Oct?'), findsOneWidget);
      await robot.confirmDelete();

      expect(robot.groceryListWeeks, ['26 Oct – 1 Nov']);
      final weeks = (await lists.findAll()).map((l) => l.week.start);
      expect(weeks, [DateTime(2026, 10, 26)]);
    },
    variant: TargetPlatformVariant.only(TargetPlatform.macOS),
  );

  testWidgets('on a phone the lists have no delete buttons, you swipe', (
    tester,
  ) async {
    await launchWithTwoLists(tester);

    expect(robot.listHasDeleteButtons, isFalse);
  });

  testWidgets('cancelling the confirmation keeps the grocery list', (
    tester,
  ) async {
    await launchWithTwoLists(tester);

    await robot.openGroceryList('19 – 25 Oct');
    await robot.deleteOpenGroceryList();
    await robot.cancelDelete();

    expect(find.text('Delete the list for 19 – 25 Oct?'), findsNothing);
    expect(robot.groceryList, ['Spaghetti 320 g']);
    expect(await lists.findAll(), hasLength(2));
  });

  testWidgets('after deleting the last list, the lists screen is empty', (
    tester,
  ) async {
    await launchWithTwoLists(tester);

    for (final week in ['19 – 25 Oct', '26 Oct – 1 Nov']) {
      await robot.openGroceryList(week);
      await robot.deleteOpenGroceryList();
      await robot.confirmDelete();
    }

    expect(find.text('No grocery lists yet'), findsOneWidget);
    expect(await lists.findAll(), isEmpty);
  });

  testWidgets('if deleting fails, the list stays open and can retry', (
    tester,
  ) async {
    final failingLists = FailingGroceryListStorageAdapter(lists);
    await launchWithTwoLists(tester, failingLists: failingLists);
    await robot.openGroceryList('19 – 25 Oct');
    failingLists.failDeletes = true;

    await robot.deleteOpenGroceryList();
    await robot.confirmDelete();

    expect(
      find.text('Could not delete the grocery list. Please try again.'),
      findsOneWidget,
    );
    expect(robot.groceryList, ['Spaghetti 320 g']);
    expect(await lists.findAll(), hasLength(2));

    failingLists.failDeletes = false;
    await robot.deleteOpenGroceryList();
    await robot.confirmDelete();

    expect(find.text('Grocery lists'), findsOneWidget);
    expect(robot.groceryListWeeks, ['26 Oct – 1 Nov']);
  });

  testWidgets('swiping a list left on the lists screen deletes it', (
    tester,
  ) async {
    await launchWithTwoLists(tester);

    await robot.swipeToDelete('19 – 25 Oct');
    expect(find.text('Delete the list for 19 – 25 Oct?'), findsOneWidget);
    await robot.confirmDelete();

    expect(robot.groceryListWeeks, ['26 Oct – 1 Nov']);
    final weeks = (await lists.findAll()).map((l) => l.week.start);
    expect(weeks, [DateTime(2026, 10, 26)]);
  });

  testWidgets('cancelling a swipe keeps the list on the lists screen', (
    tester,
  ) async {
    await launchWithTwoLists(tester);

    await robot.swipeToDelete('19 – 25 Oct');
    await robot.cancelDelete();

    expect(robot.groceryListWeeks, ['19 – 25 Oct', '26 Oct – 1 Nov']);
    expect(await lists.findAll(), hasLength(2));
  });

  testWidgets('if deleting by swipe fails, the list stays and can retry', (
    tester,
  ) async {
    final failingLists = FailingGroceryListStorageAdapter(lists);
    await launchWithTwoLists(tester, failingLists: failingLists);
    failingLists.failDeletes = true;

    await robot.swipeToDelete('19 – 25 Oct');
    await robot.confirmDelete();

    expect(
      find.text('Could not delete the grocery list. Please try again.'),
      findsOneWidget,
    );
    expect(robot.groceryListWeeks, ['19 – 25 Oct', '26 Oct – 1 Nov']);
    expect(await lists.findAll(), hasLength(2));

    failingLists.failDeletes = false;
    await robot.swipeToDelete('19 – 25 Oct');
    await robot.confirmDelete();

    expect(robot.groceryListWeeks, ['26 Oct – 1 Nov']);
    expect(
      find.text('Could not delete the grocery list. Please try again.'),
      findsNothing,
    );
  });
}
