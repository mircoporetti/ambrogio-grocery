import 'package:ambrogio_grocery/recipes/data/drift_recipe_storage_adapter.dart';
import 'package:ambrogio_grocery/recipes/domain/ingredient.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/recipe_robot.dart';
import 'support/test_database.dart';

void main() {
  testWidgets('recipes are still there after the app restarts', (tester) async {
    final robot = RecipeRobot(tester);
    final file = newDatabaseFile();

    final firstLaunch = openFileDatabase(file);
    await robot.launchApp(DriftRecipeStorageAdapter(firstLaunch));
    await robot.startNewRecipe();
    await robot.enterTitle('Carbonara');
    await robot.enterPortions('4');
    await robot.addIngredient('Spaghetti', '320', 'g');
    await robot.addIngredient('Milk', '1,5', 'ml');
    await robot.enterProcedure('Boil the pasta.');
    await robot.addCategory('Pasta');
    await robot.addCategory('Dinner');
    await robot.save();
    await robot.closeApp();
    await firstLaunch.close();

    final secondLaunch = openFileDatabase(file);
    addTearDown(secondLaunch.close);
    final storage = DriftRecipeStorageAdapter(secondLaunch);
    await robot.launchApp(storage);

    expect(find.text('Carbonara'), findsOneWidget);
    expect(find.text('4 portions · Pasta, Dinner'), findsOneWidget);
    final recipe = (await storage.findAll()).single;
    expect(recipe.ingredients, [
      Ingredient(name: 'Spaghetti', quantity: 320, unit: MeasureUnit.grams),
      Ingredient(name: 'Milk', quantity: 1.5, unit: MeasureUnit.milliliters),
    ]);
    expect(recipe.procedure, 'Boil the pasta.');
  });

  testWidgets('recipes keep the order they were created in', (tester) async {
    final robot = RecipeRobot(tester);
    final file = newDatabaseFile();

    final firstLaunch = openFileDatabase(file);
    await robot.launchApp(DriftRecipeStorageAdapter(firstLaunch));
    for (final title in ['Carbonara', 'Pancakes', 'Risotto']) {
      await robot.startNewRecipe();
      await robot.enterTitle(title);
      await robot.enterPortions('2');
      await robot.addIngredient('Salt', '5', 'g');
      await robot.save();
    }
    await robot.closeApp();
    await firstLaunch.close();

    final secondLaunch = openFileDatabase(file);
    addTearDown(secondLaunch.close);
    final storage = DriftRecipeStorageAdapter(secondLaunch);
    await robot.launchApp(storage);

    final titles = (await storage.findAll()).map((r) => r.title);
    expect(titles, ['Carbonara', 'Pancakes', 'Risotto']);
  });
}
