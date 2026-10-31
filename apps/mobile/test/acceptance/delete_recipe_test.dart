import 'package:ambrogio_grocery/recipes/data/drift_recipe_storage_adapter.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/failing_recipe_storage_adapter.dart';
import 'support/fake_photo_picker_adapter.dart';
import 'support/fake_photo_storage_adapter.dart';
import 'support/recipe_robot.dart';
import 'support/screen.dart';
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

  Future<void> createRecipe(String title) async {
    await robot.startNewRecipe();
    await robot.enterTitle(title);
    await robot.enterPortions('2');
    await robot.addIngredient('Salt', '5', 'g');
    await robot.save();
  }

  testWidgets('a deleted recipe disappears from the list', (tester) async {
    robot = RecipeRobot(tester);
    await robot.launchApp(storage);
    await createRecipe('Carbonara');
    await createRecipe('Pancakes');

    await robot.openRecipe('Carbonara');
    await robot.deleteOpenRecipe();
    expect(find.text('Delete Carbonara?'), findsOneWidget);
    await robot.confirmDelete();

    expect(find.text('Recipes'), findsOneWidget);
    expect(find.text('Carbonara'), findsNothing);
    expect(find.text('Pancakes'), findsOneWidget);
    final titles = (await storage.findAll()).map((r) => r.title);
    expect(titles, ['Pancakes']);
  });

  group('with a mouse, where swiping is awkward,', () {
    final computer = TargetPlatformVariant.only(TargetPlatform.macOS);

    testWidgets('a recipe is deleted with its button in the list', (
      tester,
    ) async {
      robot = RecipeRobot(tester);
      await robot.launchApp(storage);
      await createRecipe('Carbonara');
      await createRecipe('Pancakes');

      await robot.deleteFromList('Carbonara');
      expect(find.text('Delete Carbonara?'), findsOneWidget);
      await robot.confirmDelete();

      expect(find.text('Carbonara'), findsNothing);
      expect((await storage.findAll()).map((r) => r.title), ['Pancakes']);
    }, variant: computer);

    testWidgets('a recipe card on a wide screen has its button too', (
      tester,
    ) async {
      useScreen(tester, computerScreen);
      robot = RecipeRobot(tester);
      await robot.launchApp(storage);
      await createRecipe('Carbonara');
      await createRecipe('Pancakes');

      await robot.deleteFromList('Pancakes');
      await robot.confirmDelete();

      expect(find.text('Pancakes'), findsNothing);
      expect((await storage.findAll()).map((r) => r.title), ['Carbonara']);
    }, variant: computer);
  });

  testWidgets('on a phone the list has no delete buttons, you swipe', (
    tester,
  ) async {
    robot = RecipeRobot(tester);
    await robot.launchApp(storage);
    await createRecipe('Carbonara');

    expect(robot.listHasDeleteButtons, isFalse);
  });

  testWidgets('cancelling the confirmation keeps the recipe', (tester) async {
    robot = RecipeRobot(tester);
    await robot.launchApp(storage);
    await createRecipe('Carbonara');

    await robot.openRecipe('Carbonara');
    await robot.deleteOpenRecipe();
    await robot.cancelDelete();

    expect(find.text('Delete Carbonara?'), findsNothing);
    expect(find.text('Carbonara'), findsOneWidget);
    expect(find.text('Salt'), findsOneWidget);
    expect(await storage.findAll(), hasLength(1));
  });

  testWidgets('deleting a recipe also deletes its photo', (tester) async {
    final photoPicker = FakePhotoPickerAdapter()..nextPhoto = 'carbonara';
    final photoStorage = FakePhotoStorageAdapter();
    robot = RecipeRobot(tester);
    await robot.launchApp(
      storage,
      photoPicker: photoPicker,
      photoStorage: photoStorage,
    );
    await robot.startNewRecipe();
    await robot.addPhoto();
    await robot.enterTitle('Carbonara');
    await robot.enterPortions('4');
    await robot.addIngredient('Spaghetti', '320', 'g');
    await robot.save();

    await robot.openRecipe('Carbonara');
    await robot.deleteOpenRecipe();
    await robot.confirmDelete();

    expect(photoStorage.isEmpty, isTrue);
  });

  testWidgets('if deleting fails, the recipe stays and an error is shown', (
    tester,
  ) async {
    final failingStorage = FailingRecipeStorageAdapter(storage);
    robot = RecipeRobot(tester);
    await robot.launchApp(failingStorage);
    await createRecipe('Carbonara');

    await robot.openRecipe('Carbonara');
    failingStorage.failDeletes = true;
    await robot.deleteOpenRecipe();
    await robot.confirmDelete();

    expect(
      find.text('Could not delete the recipe. Please try again.'),
      findsOneWidget,
    );
    expect(find.text('Salt'), findsOneWidget);
    expect(await storage.findAll(), hasLength(1));
  });

  testWidgets('swiping a recipe left in the list deletes it', (tester) async {
    robot = RecipeRobot(tester);
    await robot.launchApp(storage);
    await createRecipe('Carbonara');
    await createRecipe('Pancakes');

    await robot.swipeToDelete('Carbonara');
    expect(find.text('Delete Carbonara?'), findsOneWidget);
    await robot.confirmDelete();

    expect(find.text('Carbonara'), findsNothing);
    expect(find.text('Pancakes'), findsOneWidget);
    final titles = (await storage.findAll()).map((r) => r.title);
    expect(titles, ['Pancakes']);
  });

  testWidgets('cancelling a swipe keeps the recipe in the list', (
    tester,
  ) async {
    robot = RecipeRobot(tester);
    await robot.launchApp(storage);
    await createRecipe('Carbonara');

    await robot.swipeToDelete('Carbonara');
    await robot.cancelDelete();

    expect(find.text('Carbonara'), findsOneWidget);
    expect(await storage.findAll(), hasLength(1));
  });

  testWidgets('deleting a recipe by swipe also deletes its photo', (
    tester,
  ) async {
    final photoPicker = FakePhotoPickerAdapter()..nextPhoto = 'carbonara';
    final photoStorage = FakePhotoStorageAdapter();
    robot = RecipeRobot(tester);
    await robot.launchApp(
      storage,
      photoPicker: photoPicker,
      photoStorage: photoStorage,
    );
    await robot.startNewRecipe();
    await robot.addPhoto();
    await robot.enterTitle('Carbonara');
    await robot.enterPortions('4');
    await robot.addIngredient('Spaghetti', '320', 'g');
    await robot.save();

    await robot.swipeToDelete('Carbonara');
    await robot.confirmDelete();

    expect(photoStorage.isEmpty, isTrue);
  });

  testWidgets('if deleting by swipe fails, the recipe stays and can retry', (
    tester,
  ) async {
    final failingStorage = FailingRecipeStorageAdapter(storage);
    robot = RecipeRobot(tester);
    await robot.launchApp(failingStorage);
    await createRecipe('Carbonara');
    failingStorage.failDeletes = true;

    await robot.swipeToDelete('Carbonara');
    await robot.confirmDelete();

    expect(
      find.text('Could not delete the recipe. Please try again.'),
      findsOneWidget,
    );
    expect(find.text('Carbonara'), findsOneWidget);
    expect(await storage.findAll(), hasLength(1));

    failingStorage.failDeletes = false;
    await robot.swipeToDelete('Carbonara');
    await robot.confirmDelete();

    expect(find.text('Carbonara'), findsNothing);
    expect(find.text('No recipes yet'), findsOneWidget);
    expect(
      find.text('Could not delete the recipe. Please try again.'),
      findsNothing,
    );
  });
}
