import 'package:ambrogio_grocery/recipes/data/drift_recipe_storage_adapter.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/account_robot.dart';
import 'support/fake_account_api_adapter.dart';
import 'support/recipe_robot.dart';
import 'support/test_database.dart';
import 'support/test_secure_storage.dart';

void main() {
  late FakeAccountApiAdapter api;
  late AccountRobot robot;

  setUp(() => api = FakeAccountApiAdapter());

  Future<void> launchApp(WidgetTester tester, {bool restart = false}) async {
    await RecipeRobot(tester).launchApp(
      DriftRecipeStorageAdapter(
        openInMemoryDatabase(),
        documentsDir: testDocumentsDir,
      ),
      accountApi: api,
      sessionStorage: restart ? reopenedSecureStorage() : emptySecureStorage(),
    );
    robot = AccountRobot(tester);
  }

  Future<void> restartApp(WidgetTester tester) async {
    await RecipeRobot(tester).closeApp();
    await launchApp(tester, restart: true);
  }

  testWidgets('by default you are not logged in', (tester) async {
    await launchApp(tester);

    await robot.openSettings();

    expect(robot.accountSetting, 'Not logged in');
    expect(find.text('Log out'), findsNothing);
  });

  testWidgets('the app works without an account', (tester) async {
    await launchApp(tester);
    final recipes = RecipeRobot(tester);

    await recipes.startNewRecipe();
    await recipes.enterTitle('Carbonara');
    await recipes.enterPortions('4');
    await recipes.addIngredient('Spaghetti', '320', 'g');
    await recipes.save();

    expect(find.text('Carbonara'), findsOneWidget);
  });

  testWidgets('logging in shows the account in the settings', (tester) async {
    api.givenAccount('ada@example.com', 'secret-pw');
    await launchApp(tester);

    await robot.logIn('Ada@Example.com', 'secret-pw');

    expect(robot.pageTitle, 'Settings');
    expect(robot.accountSetting, 'ada@example.com');
    expect(find.text('Log out'), findsOneWidget);
  });

  testWidgets('creating an account logs you in', (tester) async {
    await launchApp(tester);

    await robot.createAccount('ada@example.com', 'secret-pw');

    expect(robot.pageTitle, 'Settings');
    expect(robot.accountSetting, 'ada@example.com');
  });

  testWidgets('a wrong password shows an error and keeps the input', (
    tester,
  ) async {
    api.givenAccount('ada@example.com', 'secret-pw');
    await launchApp(tester);

    await robot.logIn('ada@example.com', 'wrong-pw');

    expect(find.text('Wrong email or password.'), findsOneWidget);
    expect(robot.pageTitle, 'Log in');
    expect(robot.fieldText('Email'), 'ada@example.com');

    await robot.enterPassword('secret-pw');
    await robot.submit();

    expect(robot.accountSetting, 'ada@example.com');
  });

  testWidgets('creating an account shows why it was refused', (tester) async {
    api.givenAccount('ada@example.com', 'secret-pw');
    await launchApp(tester);
    await robot.openSettings();
    await robot.openLogIn();
    await robot.switchToCreateAccount();

    final cases = {
      ('ada@example.com', 'other-pw-1'):
          'An account with this email already exists.',
      ('ada', 'secret-pw'): 'Enter a valid email address.',
      ('bob@example.com', 'short'):
          'The password must be at least 8 characters.',
    };
    for (final MapEntry(key: (email, password), value: message)
        in cases.entries) {
      await robot.enterEmail(email);
      await robot.enterPassword(password);
      await robot.submit();

      expect(find.text(message), findsOneWidget, reason: email);
      expect(robot.pageTitle, 'Create account');
    }
  });

  testWidgets('email and password are required', (tester) async {
    await launchApp(tester);
    await robot.openSettings();
    await robot.openLogIn();

    await robot.submit();

    expect(find.text('Email is required'), findsOneWidget);
    expect(find.text('Password is required'), findsOneWidget);
  });

  testWidgets('you can switch between logging in and creating an account', (
    tester,
  ) async {
    await launchApp(tester);
    await robot.openSettings();
    await robot.openLogIn();
    expect(robot.pageTitle, 'Log in');

    await robot.switchToCreateAccount();
    expect(robot.pageTitle, 'Create account');

    await robot.switchToLogIn();
    expect(robot.pageTitle, 'Log in');
  });

  testWidgets('if the server is unreachable, an error is shown and you can '
      'retry', (tester) async {
    api.givenAccount('ada@example.com', 'secret-pw');
    await launchApp(tester);
    api.unreachable = true;

    await robot.logIn('ada@example.com', 'secret-pw');

    expect(
      find.text(
        'Could not reach the server. Check your connection and try again.',
      ),
      findsOneWidget,
    );
    expect(robot.pageTitle, 'Log in');

    api.unreachable = false;
    await robot.submit();

    expect(robot.accountSetting, 'ada@example.com');
  });

  testWidgets('you stay logged in after restarting the app', (tester) async {
    api.givenAccount('ada@example.com', 'secret-pw');
    await launchApp(tester);
    await robot.logIn('ada@example.com', 'secret-pw');

    await restartApp(tester);
    await robot.openSettings();

    expect(robot.accountSetting, 'ada@example.com');
  });

  testWidgets('logging out ends the session on the server too', (tester) async {
    api.givenAccount('ada@example.com', 'secret-pw');
    await launchApp(tester);
    await robot.logIn('ada@example.com', 'secret-pw');

    await robot.logOut();

    expect(robot.accountSetting, 'Not logged in');
    expect(api.loggedOut, ['refresh-1']);

    await restartApp(tester);
    await robot.openSettings();
    expect(robot.accountSetting, 'Not logged in');
  });

  testWidgets('logging out works without a connection', (tester) async {
    api.givenAccount('ada@example.com', 'secret-pw');
    await launchApp(tester);
    await robot.logIn('ada@example.com', 'secret-pw');
    api.unreachable = true;

    await robot.logOut();

    expect(robot.accountSetting, 'Not logged in');
  });
}
