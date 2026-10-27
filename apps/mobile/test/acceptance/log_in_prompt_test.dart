import 'package:ambrogio_grocery/account/data/shared_preferences_log_in_prompt_adapter.dart';
import 'package:ambrogio_grocery/account/domain/log_in_prompt_port.dart';
import 'package:ambrogio_grocery/recipes/data/drift_recipe_storage_adapter.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/account_robot.dart';
import 'support/fake_account_api_adapter.dart';
import 'support/recipe_robot.dart';
import 'support/test_database.dart';
import 'support/test_preferences.dart';
import 'support/test_secure_storage.dart';

void main() {
  late FakeAccountApiAdapter api;
  late LogInPromptPort prompt;
  late AccountRobot robot;

  setUp(() {
    api = FakeAccountApiAdapter()..givenAccount('ada@example.com', 'secret-pw');
    prompt = SharedPreferencesLogInPromptAdapter(inMemoryPreferences());
  });

  Future<void> launchApp(WidgetTester tester, {bool restart = false}) async {
    await RecipeRobot(tester).launchApp(
      DriftRecipeStorageAdapter(
        openInMemoryDatabase(),
        documentsDir: testDocumentsDir,
      ),
      accountApi: api,
      sessionStorage: restart ? reopenedSecureStorage() : emptySecureStorage(),
      logInPrompt: prompt,
    );
    robot = AccountRobot(tester);
  }

  Future<void> restartApp(WidgetTester tester) async {
    await RecipeRobot(tester).closeApp();
    await launchApp(tester, restart: true);
  }

  testWidgets('on the first launch you are asked to log in', (tester) async {
    await launchApp(tester);

    expect(robot.isAskedToLogIn, isTrue);
    expect(robot.pageTitle, 'Log in');
    expect(find.text('Skip'), findsOneWidget);
  });

  testWidgets('skipping shows the recipes and does not ask again', (
    tester,
  ) async {
    await launchApp(tester);

    await robot.skipLogIn();

    expect(robot.pageTitle, 'Recipes');
    await robot.openSettings();
    expect(robot.accountSetting, 'Not logged in');

    await restartApp(tester);
    expect(robot.isAskedToLogIn, isFalse);
    expect(robot.pageTitle, 'Recipes');
  });

  testWidgets('going back closes the prompt like skipping', (tester) async {
    await launchApp(tester);

    await robot.goBackWithSystemButton();

    expect(robot.pageTitle, 'Recipes');
    await restartApp(tester);
    expect(robot.isAskedToLogIn, isFalse);
  });

  testWidgets('logging in from the prompt shows the recipes', (tester) async {
    await launchApp(tester);

    await robot.enterEmail('ada@example.com');
    await robot.enterPassword('secret-pw');
    await robot.submit();

    expect(robot.pageTitle, 'Recipes');
    await robot.openSettings();
    expect(robot.accountSetting, 'ada@example.com');
  });

  testWidgets('creating an account from the prompt shows the recipes', (
    tester,
  ) async {
    await launchApp(tester);

    await robot.switchToCreateAccount();
    expect(robot.isAskedToLogIn, isTrue);
    await robot.enterEmail('bob@example.com');
    await robot.enterPassword('secret-pw');
    await robot.submit();

    expect(robot.pageTitle, 'Recipes');
    await robot.openSettings();
    expect(robot.accountSetting, 'bob@example.com');
  });

  testWidgets('a failed login keeps the prompt open', (tester) async {
    await launchApp(tester);

    await robot.enterEmail('ada@example.com');
    await robot.enterPassword('wrong-pw');
    await robot.submit();

    expect(find.text('Wrong email or password.'), findsOneWidget);
    expect(robot.isAskedToLogIn, isTrue);
  });

  testWidgets('after logging out you are not asked again', (tester) async {
    await launchApp(tester);
    await robot.enterEmail('ada@example.com');
    await robot.enterPassword('secret-pw');
    await robot.submit();
    await robot.openSettings();
    await robot.logOut();

    await restartApp(tester);

    expect(robot.isAskedToLogIn, isFalse);
    expect(robot.pageTitle, 'Recipes');
  });

  testWidgets('you are not asked when you are already logged in', (
    tester,
  ) async {
    final answered = await answeredLogInPrompt();
    await RecipeRobot(tester).launchApp(
      DriftRecipeStorageAdapter(
        openInMemoryDatabase(),
        documentsDir: testDocumentsDir,
      ),
      accountApi: api,
      sessionStorage: emptySecureStorage(),
      logInPrompt: answered,
    );
    robot = AccountRobot(tester);
    await robot.logIn('ada@example.com', 'secret-pw');
    await RecipeRobot(tester).closeApp();

    await launchApp(tester, restart: true);

    expect(robot.isAskedToLogIn, isFalse);
    expect(robot.pageTitle, 'Recipes');
  });
}
