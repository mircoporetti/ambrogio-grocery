import 'package:ambrogio_grocery/recipes/data/drift_recipe_storage_adapter.dart';
import 'package:ambrogio_grocery/recipes/domain/ingredient.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/failing_recipe_storage_adapter.dart';
import 'support/fake_photo_picker_adapter.dart';
import 'support/fake_photo_storage_adapter.dart';
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

  Future<void> createCarbonara() async {
    await robot.startNewRecipe();
    await robot.enterTitle('Carbonara');
    await robot.enterPortions('4');
    await robot.addIngredient('Spaghetti', '320', 'g');
    await robot.addIngredient('Guanciale', '100', 'g');
    await robot.enterProcedure('Boil the pasta.');
    await robot.addCategory('Pasta');
    await robot.save();
  }

  testWidgets('the edit form starts with the recipe data and saves changes', (
    tester,
  ) async {
    robot = RecipeRobot(tester);
    await robot.launchApp(storage);
    await createCarbonara();
    final id = (await storage.findAll()).single.id;

    await robot.openRecipe('Carbonara');
    await robot.editOpenRecipe();

    expect(robot.fieldText('Title'), 'Carbonara');
    expect(robot.fieldText('Portions'), '4');
    expect(robot.fieldText('Procedure (optional)'), 'Boil the pasta.');
    expect(find.text('Spaghetti'), findsOneWidget);
    expect(find.text('Guanciale'), findsOneWidget);
    expect(find.text('Pasta'), findsOneWidget);

    await robot.enterTitle('Carbonara classica');
    await robot.enterPortions('2');
    await robot.removeIngredient('Guanciale');
    await robot.addIngredient('Pecorino', '50', 'g');
    await robot.enterProcedure('Boil the pasta al dente.');
    await robot.removeCategory('Pasta');
    await robot.addCategory('Dinner');
    await robot.save();

    expect(find.text('Carbonara classica'), findsOneWidget);
    expect(find.text('2 portions'), findsOneWidget);
    expect(find.text('Pecorino'), findsOneWidget);
    expect(find.text('50 g'), findsOneWidget);
    expect(find.text('Guanciale'), findsNothing);
    expect(find.text('Dinner'), findsOneWidget);
    expect(find.text('Pasta'), findsNothing);
    expect(find.text('Boil the pasta al dente.'), findsOneWidget);

    await robot.goBack();
    expect(find.text('Carbonara classica'), findsOneWidget);
    expect(find.text('2 portions · Dinner'), findsOneWidget);

    final saved = (await storage.findAll()).single;
    expect(saved.id, id);
    expect(saved.ingredients, [
      Ingredient(name: 'Spaghetti', quantity: 320, unit: MeasureUnit.grams),
      Ingredient(name: 'Pecorino', quantity: 50, unit: MeasureUnit.grams),
    ]);
    expect(saved.categories, ['Dinner']);
  });

  testWidgets('leaving the edit form without saving changes nothing', (
    tester,
  ) async {
    robot = RecipeRobot(tester);
    await robot.launchApp(storage);
    await createCarbonara();

    await robot.openRecipe('Carbonara');
    await robot.editOpenRecipe();
    await robot.enterTitle('Something else');
    await robot.goBack();

    expect(find.text('Carbonara'), findsOneWidget);
    expect((await storage.findAll()).single.title, 'Carbonara');
  });

  testWidgets('if saving the changes fails, the form keeps them', (
    tester,
  ) async {
    final failingStorage = FailingRecipeStorageAdapter(storage);
    robot = RecipeRobot(tester);
    await robot.launchApp(failingStorage);
    await createCarbonara();

    await robot.openRecipe('Carbonara');
    await robot.editOpenRecipe();
    await robot.enterTitle('Carbonara classica');
    failingStorage.failSaves = true;
    await robot.save();

    expect(
      find.text('Could not save the recipe. Please try again.'),
      findsOneWidget,
    );
    expect(find.text('Edit recipe'), findsOneWidget);
    expect(robot.fieldText('Title'), 'Carbonara classica');
    expect((await storage.findAll()).single.title, 'Carbonara');

    failingStorage.failSaves = false;
    await robot.save();

    expect(find.text('Carbonara classica'), findsOneWidget);
    expect((await storage.findAll()).single.title, 'Carbonara classica');
  });

  testWidgets('replacing the photo deletes the old one', (tester) async {
    final photoPicker = FakePhotoPickerAdapter()..nextPhoto = 'old';
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
    final oldPath = robot.photoInList('Carbonara')!;

    await robot.openRecipe('Carbonara');
    await robot.editOpenRecipe();
    photoPicker.nextPhoto = 'new';
    await robot.changePhoto();
    await robot.save();
    await robot.goBack();

    expect(
      photoStorage.fileAt(robot.photoInList('Carbonara')!),
      FakePhotoPickerAdapter.bytesOf('new'),
    );
    expect(photoStorage.fileAt(oldPath), isNull);
  });

  testWidgets('saving without changing the photo keeps it', (tester) async {
    final photoPicker = FakePhotoPickerAdapter()..nextPhoto = 'old';
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
    final path = robot.photoInList('Carbonara')!;

    await robot.openRecipe('Carbonara');
    await robot.editOpenRecipe();
    await robot.enterTitle('Carbonara classica');
    await robot.save();
    await robot.goBack();

    expect(robot.photoInList('Carbonara classica'), path);
    expect(photoStorage.fileAt(path), FakePhotoPickerAdapter.bytesOf('old'));
  });
}
