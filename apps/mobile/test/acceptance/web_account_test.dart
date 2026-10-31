import 'package:ambrogio_grocery/account/data/browser_session_adapter.dart';
import 'package:ambrogio_grocery/recipes/data/drift_recipe_storage_adapter.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'support/account_robot.dart';
import 'support/fake_account_api_adapter.dart';
import 'support/fake_recipe_sync_api_adapter.dart';
import 'support/recipe_robot.dart';
import 'support/test_database.dart';
import 'support/test_preferences.dart';

const ada = 'ada@example.com';
const password = 'secret-pw';

void main() {
  late FakeAccountApiAdapter accounts;
  late FakeRecipeSyncApiAdapter server;
  late DriftRecipeStorageAdapter storage;
  late SharedPreferencesAsync preferences;
  late AccountRobot account;
  late RecipeRobot recipes;

  setUp(() {
    accounts = FakeAccountApiAdapter(refreshInCookie: true)
      ..givenAccount(ada, password);
    server = FakeRecipeSyncApiAdapter(accounts);
    storage = DriftRecipeStorageAdapter(
      openInMemoryDatabase(),
      documentsDir: testDocumentsDir,
    );
  });

  Future<void> openPage(WidgetTester tester) async {
    recipes = RecipeRobot(tester);
    account = AccountRobot(tester);
    await recipes.launchApp(
      storage,
      accountApi: accounts,
      recipeSyncApi: server,
      sessionStorage: BrowserSessionAdapter(preferences),
    );
  }

  Future<void> reloadPage(WidgetTester tester) async {
    await recipes.closeApp();
    await openPage(tester);
  }

  Future<void> openNewPage(WidgetTester tester) async {
    preferences = inMemoryPreferences();
    await openPage(tester);
  }

  Future<void> createRecipe(String title) async {
    await recipes.startNewRecipe();
    await recipes.enterTitle(title);
    await recipes.enterPortions('2');
    await recipes.addIngredient('Salt', '5', 'g');
    await recipes.save();
  }

  testWidgets('you stay logged in after reloading the page, even offline', (
    tester,
  ) async {
    await openNewPage(tester);
    await account.logIn(ada, password);
    await account.goBackWithSystemButton();
    await createRecipe('Carbonara');
    accounts.unreachable = true;
    server.unreachable = true;

    await reloadPage(tester);

    expect(find.text('Carbonara'), findsOneWidget);
    await account.openSettings();
    expect(account.accountSetting, ada);
  });

  testWidgets('after a reload the session is renewed from the cookie', (
    tester,
  ) async {
    await openNewPage(tester);
    await account.logIn(ada, password);
    await account.goBackWithSystemButton();

    await reloadPage(tester);
    await createRecipe('Carbonara');

    expect([for (final r in server.recipesOf(ada)) r.title], ['Carbonara']);
  });

  testWidgets('the page never stores a token', (tester) async {
    await openNewPage(tester);
    await account.logIn(ada, password);

    final stored = await preferences.getAll();
    expect(stored.values, isNot(contains(startsWith('access-'))));
    expect(stored.values, isNot(contains(startsWith('refresh-'))));
  });

  testWidgets('logging out ends the session in the cookie', (tester) async {
    await openNewPage(tester);
    await account.logIn(ada, password);

    await account.logOut();
    await reloadPage(tester);
    await account.openSettings();

    expect(account.accountSetting, 'Not logged in');
    expect(accounts.hasCookieSession, isFalse);
  });
}
