import 'package:ambrogio_grocery/recipes/data/drift_recipe_storage_adapter.dart';
import 'package:ambrogio_grocery/recipes/domain/ingredient.dart';
import 'package:ambrogio_grocery/recipes/domain/recipe.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/grocery_robot.dart';
import 'support/recipe_robot.dart';
import 'support/test_database.dart';

void main() {
  late DriftRecipeStorageAdapter storage;
  late GroceryRobot robot;

  setUp(
    () => storage = DriftRecipeStorageAdapter(
      openInMemoryDatabase(),
      documentsDir: testDocumentsDir,
    ),
  );

  Ingredient grams(String name, double quantity) =>
      Ingredient(name: name, quantity: quantity, unit: MeasureUnit.grams);

  Ingredient ml(String name, double quantity) =>
      Ingredient(name: name, quantity: quantity, unit: MeasureUnit.milliliters);

  Future<void> givenRecipe(
    String title,
    List<Ingredient> ingredients, {
    int portions = 2,
  }) => storage.save(
    Recipe(title: title, portions: portions, ingredients: ingredients),
  );

  Future<void> launchApp(WidgetTester tester) async {
    await RecipeRobot(tester).launchApp(storage);
    robot = GroceryRobot(tester);
  }

  testWidgets('the grocery list has the ingredients of the chosen recipes', (
    tester,
  ) async {
    await givenRecipe('Carbonara', [
      grams('Spaghetti', 320),
      grams('Guanciale', 150),
    ]);
    await givenRecipe('Pancakes', [grams('Flour', 100), ml('Milk', 200)]);
    await givenRecipe('Risotto', [grams('Rice', 300), ml('Broth', 1000)]);
    await launchApp(tester);

    await robot.startPlanningWeek();
    await robot.cook();
    await robot.skip();
    await robot.cook();
    await robot.createGroceryList();

    expect(find.text('Grocery list'), findsOneWidget);
    expect(robot.groceryList, [
      'Broth 1000 ml',
      'Guanciale 150 g',
      'Rice 300 g',
      'Spaghetti 320 g',
    ]);
  });

  testWidgets('the same ingredient in several recipes is added up', (
    tester,
  ) async {
    await givenRecipe('Carbonara', [
      grams('Spaghetti', 320),
      ml('Cream', 100),
      ml('Oil', 0.1),
    ]);
    await givenRecipe('Amatriciana', [
      grams('spaghetti', 280),
      grams('Cream', 50),
      ml('oil', 0.2),
    ]);
    await launchApp(tester);

    await robot.startPlanningWeek();
    await robot.cook();
    await robot.cook();
    await robot.createGroceryList();

    expect(robot.groceryList, [
      'Cream 50 g',
      'Cream 100 ml',
      'Oil 0.3 ml',
      'Spaghetti 600 g',
    ]);
  });

  testWidgets('swiping right chooses a recipe, swiping left skips it', (
    tester,
  ) async {
    await givenRecipe('Carbonara', [grams('Spaghetti', 320)], portions: 4);
    await givenRecipe('Pancakes', [grams('Flour', 100)], portions: 1);
    await launchApp(tester);

    await robot.startPlanningWeek();
    expect(find.text('Carbonara'), findsOneWidget);
    expect(find.text('4 portions'), findsOneWidget);
    expect(find.text('1 of 2'), findsOneWidget);
    await robot.swipeToSkip();

    expect(find.text('Pancakes'), findsOneWidget);
    expect(find.text('1 portion'), findsOneWidget);
    expect(find.text('2 of 2'), findsOneWidget);
    await robot.swipeToCook();

    expect(find.text('1 recipe chosen'), findsOneWidget);
    await robot.createGroceryList();
    expect(robot.groceryList, ['Flour 100 g']);
  });

  testWidgets('a grocery list needs at least one chosen recipe', (
    tester,
  ) async {
    await givenRecipe('Carbonara', [grams('Spaghetti', 320)]);
    await givenRecipe('Pancakes', [grams('Flour', 100)]);
    await launchApp(tester);

    await robot.startPlanningWeek();
    expect(find.text('No recipes chosen yet'), findsOneWidget);
    expect(robot.canCreateGroceryList, isFalse);

    await robot.skip();
    await robot.skip();

    expect(find.text("You've seen all your recipes"), findsOneWidget);
    expect(robot.canCreateGroceryList, isFalse);
  });

  testWidgets('the list can be created before seeing all recipes', (
    tester,
  ) async {
    await givenRecipe('Carbonara', [grams('Spaghetti', 320)]);
    await givenRecipe('Pancakes', [grams('Flour', 100)]);
    await givenRecipe('Risotto', [grams('Rice', 300)]);
    await launchApp(tester);

    await robot.startPlanningWeek();
    await robot.cook();
    await robot.cook();

    expect(find.text('2 recipes chosen'), findsOneWidget);
    await robot.createGroceryList();
    expect(robot.groceryList, ['Flour 100 g', 'Spaghetti 320 g']);
  });

  testWidgets('without recipes, planning asks to add some first', (
    tester,
  ) async {
    await launchApp(tester);

    await robot.startPlanningWeek();

    expect(find.text('Add some recipes to plan your week'), findsOneWidget);
    expect(robot.canCreateGroceryList, isFalse);
  });

  testWidgets('going back from the grocery list returns to the saved lists', (
    tester,
  ) async {
    await givenRecipe('Carbonara', [grams('Spaghetti', 320)]);
    await launchApp(tester);
    await robot.startPlanningWeek();
    await robot.cook();
    await robot.createGroceryList();

    await robot.goBack();

    expect(find.text('Grocery lists'), findsOneWidget);
    expect(robot.groceryListWeeks, ['19 – 25 Oct']);
  });
}
