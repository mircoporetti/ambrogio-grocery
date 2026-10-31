import 'package:ambrogio_grocery/recipes/data/drift_recipe_storage_adapter.dart';
import 'package:ambrogio_grocery/recipes/domain/ingredient.dart';
import 'package:ambrogio_grocery/recipes/domain/recipe.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/account_robot.dart';
import 'support/grocery_robot.dart';
import 'support/recipe_robot.dart';
import 'support/screen.dart';
import 'support/test_database.dart';

void main() {
  late DriftRecipeStorageAdapter storage;
  late RecipeRobot recipes;
  late GroceryRobot grocery;

  setUp(
    () => storage = DriftRecipeStorageAdapter(
      openInMemoryDatabase(),
      documentsDir: testDocumentsDir,
    ),
  );

  Future<void> givenRecipe(String title, String ingredient) => storage.save(
    Recipe(
      title: title,
      portions: 2,
      ingredients: [
        Ingredient(name: ingredient, quantity: 100, unit: MeasureUnit.grams),
      ],
    ),
  );

  Future<void> launchApp(WidgetTester tester, Size screen) async {
    useScreen(tester, screen);
    recipes = RecipeRobot(tester);
    grocery = GroceryRobot(tester);
    await recipes.launchApp(storage);
  }

  double widthOf(WidgetTester tester, Finder finder) =>
      tester.getSize(finder).width;

  group('on a computer', () {
    testWidgets('recipes are shown side by side as cards', (tester) async {
      await givenRecipe('Carbonara', 'Spaghetti');
      await givenRecipe('Pancakes', 'Flour');
      await launchApp(tester, computerScreen);

      final carbonara = tester.getCenter(find.text('Carbonara'));
      final pancakes = tester.getCenter(find.text('Pancakes'));
      expect(pancakes.dy, carbonara.dy);
      expect(pancakes.dx, greaterThan(carbonara.dx));

      await recipes.openRecipe('Pancakes');
      expect(find.text('Flour'), findsOneWidget);
    });

    testWidgets('forms keep a readable width', (tester) async {
      await launchApp(tester, computerScreen);

      await recipes.startNewRecipe();
      expect(
        widthOf(tester, find.widgetWithText(TextFormField, 'Title')),
        lessThanOrEqualTo(600),
      );

      await recipes.goBack();
      await AccountRobot(tester).openSettings();
      await AccountRobot(tester).openLogIn();
      expect(
        widthOf(tester, find.widgetWithText(TextFormField, 'Email')),
        lessThanOrEqualTo(600),
      );
    });

    testWidgets('lists keep a readable width', (tester) async {
      await launchApp(tester, computerScreen);

      await AccountRobot(tester).openSettings();

      expect(
        widthOf(tester, find.widgetWithText(ListTile, 'Language')),
        lessThanOrEqualTo(720),
      );
    });

    testWidgets('the recipe card for planning the week is not stretched', (
      tester,
    ) async {
      await givenRecipe('Carbonara', 'Spaghetti');
      await launchApp(tester, computerScreen);

      await grocery.startPlanningWeek();

      expect(widthOf(tester, find.byType(Card)), lessThanOrEqualTo(480));
      expect(
        tester.getSize(find.byType(Card)).height,
        greaterThan(computerScreen.height / 2),
      );
    });

    testWidgets('recipes for the week can be chosen with the arrow keys', (
      tester,
    ) async {
      await givenRecipe('Carbonara', 'Spaghetti');
      await givenRecipe('Pancakes', 'Flour');
      await launchApp(tester, computerScreen);
      await grocery.startPlanningWeek();

      await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
      await tester.pumpAndSettle();
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowLeft);
      await tester.pumpAndSettle();
      await grocery.createGroceryList();

      expect(grocery.groceryList, ['Spaghetti 100 g']);
    });
  });

  testWidgets('on a phone recipes stay a list', (tester) async {
    await givenRecipe('Carbonara', 'Spaghetti');
    await givenRecipe('Pancakes', 'Flour');
    await launchApp(tester, phoneScreen);

    final carbonara = tester.getCenter(find.text('Carbonara'));
    final pancakes = tester.getCenter(find.text('Pancakes'));
    expect(pancakes.dy, greaterThan(carbonara.dy));
    expect(pancakes.dx, carbonara.dx);
  });
}
