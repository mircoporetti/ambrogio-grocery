import 'package:ambrogio_grocery/recipes/data/drift_recipe_storage_adapter.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/fake_home_screen_adapter.dart';
import 'support/home_screen_robot.dart';
import 'support/recipe_robot.dart';
import 'support/test_database.dart';

void main() {
  Future<HomeScreenRobot> launchApp(
    WidgetTester tester, {
    required bool inIphoneBrowserTab,
  }) async {
    await RecipeRobot(tester).launchApp(
      DriftRecipeStorageAdapter(
        openInMemoryDatabase(),
        documentsDir: testDocumentsDir,
      ),
      homeScreen: FakeHomeScreenAdapter(inIphoneBrowserTab: inIphoneBrowserTab),
    );
    return HomeScreenRobot(tester);
  }

  testWidgets('in a browser tab on an iPhone the app asks to be added to the '
      'Home Screen', (tester) async {
    final robot = await launchApp(tester, inIphoneBrowserTab: true);

    expect(robot.isAskedToAddToHomeScreen, isTrue);

    await robot.notNow();

    expect(robot.isAskedToAddToHomeScreen, isFalse);
  });

  testWidgets('opened from the Home Screen or elsewhere it does not ask', (
    tester,
  ) async {
    final robot = await launchApp(tester, inIphoneBrowserTab: false);

    expect(robot.isAskedToAddToHomeScreen, isFalse);
  });
}
