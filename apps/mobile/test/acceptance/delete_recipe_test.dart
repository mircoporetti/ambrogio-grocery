import 'package:ambrogio_grocery/recipes/data/drift_recipe_storage_adapter.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/failing_recipe_storage_adapter.dart';
import 'support/fake_photo_picker_adapter.dart';
import 'support/fake_photo_storage_adapter.dart';
import 'support/recipe_robot.dart';
import 'support/test_database.dart';

void main() {
  late DriftRecipeStorageAdapter storage;
  late RecipeRobot robot;

  setUp(() => storage = DriftRecipeStorageAdapter(openInMemoryDatabase()));

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
    final photoPicker = FakePhotoPickerAdapter()
      ..nextPhoto = '/photos/carbonara.jpg';
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

    expect(photoStorage.deleted, ['/photos/carbonara.jpg']);
  });

  testWidgets('if deleting fails, the recipe stays and an error is shown', (
    tester,
  ) async {
    final failingStorage = FailingRecipeStorageAdapter(storage);
    final photoStorage = FakePhotoStorageAdapter();
    robot = RecipeRobot(tester);
    await robot.launchApp(failingStorage, photoStorage: photoStorage);
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
    expect(photoStorage.deleted, isEmpty);
  });
}
