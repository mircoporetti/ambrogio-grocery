import 'package:ambrogio_grocery/database/app_database.dart';
import 'package:ambrogio_grocery/grocery/data/drift_grocery_list_storage_adapter.dart';
import 'package:ambrogio_grocery/recipes/data/drift_recipe_storage_adapter.dart';
import 'package:ambrogio_grocery/recipes/domain/ingredient.dart';
import 'package:ambrogio_grocery/recipes/domain/recipe.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/failing_grocery_list_storage_adapter.dart';
import 'support/fixed_clock_adapter.dart';
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

  Future<Recipe> givenRecipe(String title, List<Ingredient> ingredients) async {
    final recipe = Recipe(title: title, portions: 2, ingredients: ingredients);
    await recipes.save(recipe);
    return recipe;
  }

  Future<void> launchApp(
    WidgetTester tester, {
    DateTime? now,
    FailingGroceryListStorageAdapter? failingLists,
  }) async {
    await RecipeRobot(tester).launchApp(
      recipes,
      groceryListStorage: failingLists ?? lists,
      clock: FixedClockAdapter(now ?? today),
    );
    robot = GroceryRobot(tester);
  }

  Future<void> planWith(int recipesToCook, {int laterWeeks = 0}) async {
    await robot.planWeek();
    for (var i = 0; i < laterWeeks; i++) {
      await robot.laterWeek();
    }
    for (var i = 0; i < recipesToCook; i++) {
      await robot.cook();
    }
    await robot.createGroceryList();
  }

  testWidgets('without saved lists, the grocery lists screen is empty', (
    tester,
  ) async {
    await launchApp(tester);

    await robot.openGroceryLists();

    expect(find.text('Grocery lists'), findsOneWidget);
    expect(find.text('No grocery lists yet'), findsOneWidget);
  });

  testWidgets('a created list is saved for this week and can be reopened', (
    tester,
  ) async {
    await givenRecipe('Carbonara', [grams('Spaghetti', 320)]);
    await givenRecipe('Risotto', [grams('Rice', 300)]);
    await launchApp(tester);
    await robot.openGroceryLists();

    await planWith(2);

    expect(find.text('19 – 25 Oct'), findsOneWidget);
    expect(find.text('Carbonara, Risotto'), findsOneWidget);
    expect(robot.groceryList, ['Rice 300 g', 'Spaghetti 320 g']);

    await robot.goBack();
    expect(find.text('Grocery lists'), findsOneWidget);
    expect(robot.groceryListWeeks, ['19 – 25 Oct']);
    expect(find.text('This week · 2 recipes'), findsOneWidget);

    await robot.openGroceryList('19 – 25 Oct');
    expect(robot.groceryList, ['Rice 300 g', 'Spaghetti 320 g']);
  });

  testWidgets('a list can be planned for a later week, not an earlier one', (
    tester,
  ) async {
    await givenRecipe('Carbonara', [grams('Spaghetti', 320)]);
    await launchApp(tester);
    await robot.openGroceryLists();

    await robot.planWeek();
    expect(find.text('19 – 25 Oct'), findsOneWidget);
    expect(robot.canChooseEarlierWeek, isFalse);

    await robot.laterWeek();
    await robot.laterWeek();
    expect(find.text('2 – 8 Nov'), findsOneWidget);
    await robot.earlierWeek();
    expect(find.text('26 Oct – 1 Nov'), findsOneWidget);
    expect(robot.canChooseEarlierWeek, isTrue);

    await robot.cook();
    await robot.createGroceryList();
    expect(find.text('26 Oct – 1 Nov'), findsOneWidget);

    await robot.goBack();
    expect(robot.groceryListWeeks, ['26 Oct – 1 Nov']);
    expect(find.text('1 recipe'), findsOneWidget);
  });

  testWidgets('lists of different weeks are kept, sorted by week', (
    tester,
  ) async {
    await givenRecipe('Carbonara', [grams('Spaghetti', 320)]);
    await launchApp(tester);
    await robot.openGroceryLists();

    await planWith(1, laterWeeks: 2);
    await robot.goBack();
    await planWith(1);
    await robot.goBack();

    expect(robot.groceryListWeeks, ['19 – 25 Oct', '2 – 8 Nov']);
  });

  testWidgets('a new list for a week with a list replaces it after asking', (
    tester,
  ) async {
    await givenRecipe('Carbonara', [grams('Spaghetti', 320)]);
    await givenRecipe('Risotto', [grams('Rice', 300)]);
    await launchApp(tester);
    await robot.openGroceryLists();
    await planWith(1);
    await robot.goBack();

    await robot.planWeek();
    await robot.skip();
    await robot.cook();
    await robot.createGroceryList();
    expect(find.text('Replace the list for 19 – 25 Oct?'), findsOneWidget);

    await robot.cancelReplace();
    expect(find.text('1 recipe chosen'), findsOneWidget);
    expect((await lists.findAll()).single.recipes, ['Carbonara']);

    await robot.createGroceryList();
    await robot.confirmReplace();
    expect(robot.groceryList, ['Rice 300 g']);

    await robot.goBack();
    expect(robot.groceryListWeeks, ['19 – 25 Oct']);
    expect((await lists.findAll()).single.recipes, ['Risotto']);
  });

  testWidgets('lists of past weeks are no longer shown', (tester) async {
    await givenRecipe('Carbonara', [grams('Spaghetti', 320)]);
    await launchApp(tester);
    await robot.openGroceryLists();
    await planWith(1);
    await robot.goBack();
    await planWith(1, laterWeeks: 1);
    await robot.goBack();
    await RecipeRobot(tester).closeApp();

    await launchApp(tester, now: today.add(const Duration(days: 7)));
    await robot.openGroceryLists();

    expect(robot.groceryListWeeks, ['26 Oct – 1 Nov']);
    expect(find.text('This week · 1 recipe'), findsOneWidget);
  });

  testWidgets('a list keeps its ingredients when a recipe changes later', (
    tester,
  ) async {
    final carbonara = await givenRecipe('Carbonara', [grams('Spaghetti', 320)]);
    await launchApp(tester);
    await robot.openGroceryLists();
    await planWith(1);

    await recipes.save(
      Recipe(
        id: carbonara.id,
        title: 'Carbonara',
        portions: 2,
        ingredients: [grams('Spaghetti', 500)],
      ),
    );
    await tester.pumpAndSettle();

    expect(robot.groceryList, ['Spaghetti 320 g']);
  });

  testWidgets('if saving fails, the choices are kept and it can retry', (
    tester,
  ) async {
    await givenRecipe('Carbonara', [grams('Spaghetti', 320)]);
    await givenRecipe('Risotto', [grams('Rice', 300)]);
    final failingLists = FailingGroceryListStorageAdapter(lists)
      ..failSaves = true;
    await launchApp(tester, failingLists: failingLists);
    await robot.openGroceryLists();

    await planWith(1);

    expect(
      find.text('Could not save the grocery list. Please try again.'),
      findsOneWidget,
    );
    expect(find.text('1 recipe chosen'), findsOneWidget);
    expect(find.text('Risotto'), findsOneWidget);
    expect(await lists.findAll(), isEmpty);

    failingLists.failSaves = false;
    await robot.createGroceryList();

    expect(robot.groceryList, ['Spaghetti 320 g']);
    expect(await lists.findAll(), hasLength(1));
  });
}
