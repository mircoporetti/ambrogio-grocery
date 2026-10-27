import 'package:ambrogio_grocery/recipes/data/drift_recipe_storage_adapter.dart';
import 'package:ambrogio_grocery/recipes/domain/ingredient.dart';
import 'package:ambrogio_grocery/recipes/domain/recipe.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/failing_recipe_storage_adapter.dart';
import 'support/fake_photo_picker_adapter.dart';
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

  testWidgets('shows an empty state when there are no recipes', (tester) async {
    robot = RecipeRobot(tester);
    await robot.launchApp(storage);

    expect(find.text('No recipes yet'), findsOneWidget);
  });

  testWidgets('a created recipe appears in the recipe list', (tester) async {
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

    expect(find.text('Recipes'), findsOneWidget);
    expect(find.text('Carbonara'), findsOneWidget);
    expect(find.text('4 portions · Pasta, Dinner'), findsOneWidget);
    expect(find.text('No recipes yet'), findsNothing);

    final saved = (await storage.findAll()).single;
    expect(saved.ingredients, [
      Ingredient(name: 'Spaghetti', quantity: 320, unit: MeasureUnit.grams),
      Ingredient(name: 'Milk', quantity: 1.5, unit: MeasureUnit.milliliters),
    ]);
    expect(saved.procedure, 'Boil the pasta.');
  });

  testWidgets('procedure and categories are optional', (tester) async {
    robot = RecipeRobot(tester);
    await robot.launchApp(storage);

    await robot.startNewRecipe();
    await robot.enterTitle('Pancakes');
    await robot.enterPortions('1');
    await robot.addIngredient('Flour', '100', 'g');
    await robot.save();

    expect(find.text('Pancakes'), findsOneWidget);
    expect(find.text('1 portion'), findsOneWidget);
    final saved = (await storage.findAll()).single;
    expect(saved.procedure, isNull);
    expect(saved.categories, isEmpty);
  });

  testWidgets('a category is added only once, whatever its case', (
    tester,
  ) async {
    robot = RecipeRobot(tester);
    await robot.launchApp(storage);

    await robot.startNewRecipe();
    await robot.enterTitle('Carbonara');
    await robot.enterPortions('4');
    await robot.addIngredient('Spaghetti', '320', 'g');
    await robot.addCategory('Pasta');
    await robot.addCategory('pasta ');
    await robot.save();

    expect(find.text('4 portions · Pasta'), findsOneWidget);
    expect((await storage.findAll()).single.categories, ['Pasta']);
  });

  testWidgets('a recipe never keeps the same category twice', (tester) async {
    await storage.save(
      Recipe(
        title: 'Carbonara',
        portions: 4,
        ingredients: [
          Ingredient(name: 'Spaghetti', quantity: 320, unit: MeasureUnit.grams),
        ],
        categories: ['Pasta', 'Dinner', ' PASTA'],
      ),
    );
    robot = RecipeRobot(tester);
    await robot.launchApp(storage);

    expect(find.text('4 portions · Pasta, Dinner'), findsOneWidget);
    expect((await storage.findAll()).single.categories, ['Pasta', 'Dinner']);
  });

  testWidgets('a recipe needs a title, valid portions and an ingredient', (
    tester,
  ) async {
    robot = RecipeRobot(tester);
    await robot.launchApp(storage);

    await robot.startNewRecipe();
    await robot.enterPortions('0');
    await robot.save();

    expect(find.text('Title is required'), findsOneWidget);
    expect(
      find.text('Portions must be a whole number of at least 1'),
      findsOneWidget,
    );
    expect(find.text('Add at least one ingredient'), findsOneWidget);
    expect(await storage.findAll(), isEmpty);
  });

  testWidgets('an ingredient needs a name and a positive quantity', (
    tester,
  ) async {
    robot = RecipeRobot(tester);
    await robot.launchApp(storage);

    await robot.startNewRecipe();
    await robot.addIngredient('', '-3', 'g');

    expect(find.text('Ingredient name is required'), findsOneWidget);
    expect(
      find.text('Quantity must be a number greater than 0'),
      findsOneWidget,
    );
  });

  testWidgets('a picked photo is saved with the recipe', (tester) async {
    final photoPicker = FakePhotoPickerAdapter()
      ..nextPhoto = '/photos/carbonara.jpg';
    robot = RecipeRobot(tester);
    await robot.launchApp(storage, photoPicker: photoPicker);

    await robot.startNewRecipe();
    await robot.addPhoto();
    await robot.enterTitle('Carbonara');
    await robot.enterPortions('4');
    await robot.addIngredient('Spaghetti', '320', 'g');
    await robot.save();

    expect(find.text('Carbonara'), findsOneWidget);
    final saved = (await storage.findAll()).single;
    expect(saved.photo?.path, '/photos/carbonara.jpg');
  });

  testWidgets('the photo stays optional if the user cancels the picker', (
    tester,
  ) async {
    final photoPicker = FakePhotoPickerAdapter()..nextPhoto = null;
    robot = RecipeRobot(tester);
    await robot.launchApp(storage, photoPicker: photoPicker);

    await robot.startNewRecipe();
    await robot.addPhoto();
    await robot.enterTitle('Pancakes');
    await robot.enterPortions('1');
    await robot.addIngredient('Flour', '100', 'g');
    await robot.save();

    final saved = (await storage.findAll()).single;
    expect(saved.photo, isNull);
  });

  testWidgets('if saving fails, the form keeps the input and can retry', (
    tester,
  ) async {
    final failingStorage = FailingRecipeStorageAdapter(storage);
    robot = RecipeRobot(tester);
    await robot.launchApp(failingStorage);

    await robot.startNewRecipe();
    await robot.enterTitle('Carbonara');
    await robot.enterPortions('4');
    await robot.addIngredient('Spaghetti', '320', 'g');
    failingStorage.failSaves = true;
    await robot.save();

    expect(
      find.text('Could not save the recipe. Please try again.'),
      findsOneWidget,
    );
    expect(find.text('New recipe'), findsOneWidget);
    expect(find.text('Carbonara'), findsOneWidget);
    expect(find.text('Spaghetti'), findsOneWidget);
    expect(await storage.findAll(), isEmpty);

    failingStorage.failSaves = false;
    await robot.save();

    expect(find.text('Recipes'), findsOneWidget);
    expect(find.text('Carbonara'), findsOneWidget);
    expect(await storage.findAll(), hasLength(1));
  });
}
