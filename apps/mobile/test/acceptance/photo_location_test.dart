import 'package:ambrogio_grocery/recipes/data/drift_recipe_storage_adapter.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/fake_photo_picker_adapter.dart';
import 'support/recipe_robot.dart';
import 'support/test_database.dart';

void main() {
  testWidgets('photos are found after the app folder moves', (tester) async {
    const oldFolder = '/containers/old-id/Documents';
    const newFolder = '/containers/new-id/Documents';
    final file = newDatabaseFile();
    final photoPicker = FakePhotoPickerAdapter()
      ..nextPhoto = '$oldFolder/photos/carbonara.jpg';
    final robot = RecipeRobot(tester);

    final firstLaunch = openFileDatabase(file);
    await robot.launchApp(
      DriftRecipeStorageAdapter(firstLaunch, documentsDir: oldFolder),
      photoPicker: photoPicker,
    );
    await robot.startNewRecipe();
    await robot.addPhoto();
    await robot.enterTitle('Carbonara');
    await robot.enterPortions('4');
    await robot.addIngredient('Spaghetti', '320', 'g');
    await robot.save();
    await robot.closeApp();
    await firstLaunch.close();

    final secondLaunch = openFileDatabase(file);
    addTearDown(secondLaunch.close);
    final storage = DriftRecipeStorageAdapter(
      secondLaunch,
      documentsDir: newFolder,
    );
    await robot.launchApp(storage);

    final recipe = (await storage.findAll()).single;
    expect(recipe.photoPath, '$newFolder/photos/carbonara.jpg');
  });
}
