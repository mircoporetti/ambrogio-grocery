import 'package:ambrogio_grocery/recipes/data/drift_recipe_storage_adapter.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/recipe_robot.dart';
import 'support/test_database.dart';

void main() {
  late DriftRecipeStorageAdapter storage;
  late RecipeRobot robot;

  setUp(
    () => storage = DriftRecipeStorageAdapter(
      openInMemoryDatabase(),
      documentsDir: testDocumentsDir,
    ),
  );

  testWidgets('tapping a recipe shows all its details', (tester) async {
    robot = RecipeRobot(tester);
    await robot.launchApp(storage);
    await robot.startNewRecipe();
    await robot.enterTitle('Carbonara');
    await robot.enterPortions('4');
    await robot.addIngredient('Spaghetti', '320', 'g');
    await robot.addIngredient('Milk', '1,5', 'ml');
    await robot.enterProcedure('Boil the pasta.');
    await robot.addCategory('Pasta');
    await robot.addCategory('Dinner');
    await robot.save();

    await robot.openRecipe('Carbonara');

    expect(find.text('Carbonara'), findsOneWidget);
    expect(find.text('4 portions'), findsOneWidget);
    expect(find.text('Pasta'), findsOneWidget);
    expect(find.text('Dinner'), findsOneWidget);
    expect(find.text('Spaghetti'), findsOneWidget);
    expect(find.text('320 g'), findsOneWidget);
    expect(find.text('Milk'), findsOneWidget);
    expect(find.text('1.5 ml'), findsOneWidget);
    expect(find.text('Boil the pasta.'), findsOneWidget);
  });

  testWidgets('a recipe without a procedure shows no procedure section', (
    tester,
  ) async {
    robot = RecipeRobot(tester);
    await robot.launchApp(storage);
    await robot.startNewRecipe();
    await robot.enterTitle('Pancakes');
    await robot.enterPortions('1');
    await robot.addIngredient('Flour', '100', 'g');
    await robot.save();

    await robot.openRecipe('Pancakes');

    expect(find.text('1 portion'), findsOneWidget);
    expect(find.text('Flour'), findsOneWidget);
    expect(find.text('Procedure'), findsNothing);
  });

  testWidgets('going back from the details returns to the recipe list', (
    tester,
  ) async {
    robot = RecipeRobot(tester);
    await robot.launchApp(storage);
    await robot.startNewRecipe();
    await robot.enterTitle('Pancakes');
    await robot.enterPortions('1');
    await robot.addIngredient('Flour', '100', 'g');
    await robot.save();
    await robot.openRecipe('Pancakes');

    await robot.goBack();

    expect(find.text('Recipes'), findsOneWidget);
    expect(find.text('Pancakes'), findsOneWidget);
  });
}
