import 'package:ambrogio_grocery/recipes/data/drift_recipe_storage_adapter.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/fake_photo_picker_adapter.dart';
import 'support/fake_photo_storage_adapter.dart';
import 'support/recipe_robot.dart';
import 'support/test_database.dart';

void main() {
  testWidgets('photos are found after the app folder moves', (tester) async {
    const oldFolder = '/containers/old-id/Documents';
    const newFolder = '/containers/new-id/Documents';
    final file = newDatabaseFile();
    final robot = RecipeRobot(tester);

    final firstLaunch = openFileDatabase(file);
    await robot.launchApp(
      DriftRecipeStorageAdapter(firstLaunch, documentsDir: oldFolder),
      photoPicker: FakePhotoPickerAdapter()..nextPhoto = 'carbonara',
      photoStorage: FakePhotoStorageAdapter(documentsDir: oldFolder),
    );
    await robot.startNewRecipe();
    await robot.addPhoto();
    await robot.enterTitle('Carbonara');
    await robot.enterPortions('4');
    await robot.addIngredient('Spaghetti', '320', 'g');
    await robot.save();
    final oldPath = robot.photoInList('Carbonara')!;
    await robot.closeApp();
    await firstLaunch.close();

    final secondLaunch = openFileDatabase(file);
    addTearDown(secondLaunch.close);
    await robot.launchApp(
      DriftRecipeStorageAdapter(secondLaunch, documentsDir: newFolder),
    );

    expect(oldPath, startsWith('$oldFolder/photos/'));
    expect(
      robot.photoInList('Carbonara'),
      oldPath.replaceFirst(oldFolder, newFolder),
    );
  });
}
