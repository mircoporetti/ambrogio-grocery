import 'package:ambrogio_grocery/database/app_database.dart';
import 'package:ambrogio_grocery/recipes/data/drift_recipe_storage_adapter.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/account_robot.dart';
import 'support/fake_account_api_adapter.dart';
import 'support/fake_recipe_sync_api_adapter.dart';
import 'support/recipe_robot.dart';
import 'support/test_database.dart';
import 'support/test_secure_storage.dart';

const ada = 'ada@example.com';
const password = 'secret-pw';

void main() {
  late FakeAccountApiAdapter accounts;
  late FakeRecipeSyncApiAdapter server;
  late DriftRecipeStorageAdapter storage;
  late RecipeRobot recipes;
  late AccountRobot account;

  setUp(() {
    accounts = FakeAccountApiAdapter()..givenAccount(ada, password);
    server = FakeRecipeSyncApiAdapter(accounts);
  });

  Future<void> launchApp(
    WidgetTester tester, {
    AppDatabase? database,
    bool restart = false,
  }) async {
    storage = DriftRecipeStorageAdapter(
      database ?? openInMemoryDatabase(),
      documentsDir: testDocumentsDir,
    );
    recipes = RecipeRobot(tester);
    account = AccountRobot(tester);
    await recipes.launchApp(
      storage,
      accountApi: accounts,
      recipeSyncApi: server,
      sessionStorage: restart ? reopenedSecureStorage() : emptySecureStorage(),
    );
  }

  Future<void> logIn() async {
    await account.logIn(ada, password);
    await account.goBackWithSystemButton();
  }

  Future<void> createRecipe(String title) async {
    await recipes.startNewRecipe();
    await recipes.enterTitle(title);
    await recipes.enterPortions('2');
    await recipes.addIngredient('Salt', '5', 'g');
    await recipes.save();
  }

  List<String> onServer() => [
    for (final recipe in server.recipesOf(ada)) recipe.title,
  ];

  testWidgets('recipes made before logging in are uploaded at login', (
    tester,
  ) async {
    await launchApp(tester);
    await createRecipe('Carbonara');
    expect(onServer(), isEmpty);

    await logIn();

    expect(onServer(), ['Carbonara']);
  });

  testWidgets('new, edited and deleted recipes are uploaded', (tester) async {
    await launchApp(tester);
    await logIn();

    await createRecipe('Carbonara');
    await createRecipe('Pancakes');
    expect(onServer(), ['Carbonara', 'Pancakes']);

    await recipes.openRecipe('Carbonara');
    await recipes.editOpenRecipe();
    await recipes.enterTitle('Carbonara classica');
    await recipes.save();
    await recipes.goBack();
    await recipes.swipeToDelete('Pancakes');
    await recipes.confirmDelete();

    expect(onServer(), ['Carbonara classica']);
  });

  testWidgets('logging in adds the account recipes to the ones on the phone', (
    tester,
  ) async {
    server.givenRecipe(ada, 'Risotto');
    await launchApp(tester);
    await createRecipe('Carbonara');

    await logIn();

    expect(find.text('Risotto'), findsOneWidget);
    expect(find.text('Carbonara'), findsOneWidget);
    expect(onServer(), unorderedEquals(['Risotto', 'Carbonara']));
  });

  testWidgets('recipes changed on another device show up when you come back '
      'to the app', (tester) async {
    await launchApp(tester);
    await logIn();

    server.givenRecipe(ada, 'Risotto');
    expect(find.text('Risotto'), findsNothing);

    await recipes.bringAppToForeground();

    expect(find.text('Risotto'), findsOneWidget);
  });

  testWidgets('changes made offline are uploaded when the server is back', (
    tester,
  ) async {
    await launchApp(tester);
    await logIn();
    server.unreachable = true;

    await createRecipe('Carbonara');

    expect(find.text('Carbonara'), findsOneWidget);
    expect(onServer(), isEmpty);

    server.unreachable = false;
    await recipes.bringAppToForeground();

    expect(onServer(), ['Carbonara']);
  });

  testWidgets('changes not uploaded yet survive closing the app', (
    tester,
  ) async {
    final file = newDatabaseFile();
    final firstRun = openFileDatabase(file);
    await launchApp(tester, database: firstRun);
    await logIn();
    server.unreachable = true;
    await createRecipe('Carbonara');
    await recipes.closeApp();
    await firstRun.close();

    server.unreachable = false;
    final secondRun = openFileDatabase(file);
    addTearDown(secondRun.close);
    await launchApp(tester, database: secondRun, restart: true);

    expect(onServer(), ['Carbonara']);
  });

  testWidgets('logging out removes the recipes from the phone and logging in '
      'brings them back', (tester) async {
    await launchApp(tester);
    await logIn();
    await createRecipe('Carbonara');

    await account.openSettings();
    await account.logOut();
    expect(account.accountSetting, 'Not logged in');
    await account.goBackWithSystemButton();

    expect(find.text('Carbonara'), findsNothing);
    expect(await storage.findAll(), isEmpty);

    await logIn();

    expect(find.text('Carbonara'), findsOneWidget);
  });

  testWidgets('logging out with changes not uploaded yet asks first', (
    tester,
  ) async {
    await launchApp(tester);
    await logIn();
    server.unreachable = true;
    await createRecipe('Carbonara');
    await account.openSettings();

    await account.logOut();
    expect(account.isWarnedAboutUnsyncedChanges, isTrue);
    await account.stayLoggedIn();

    expect(account.accountSetting, ada);

    await account.logOut();
    await account.logOutAnyway();

    expect(account.accountSetting, 'Not logged in');
    await account.goBackWithSystemButton();
    expect(find.text('Carbonara'), findsNothing);
  });

  testWidgets('an expired access token is renewed and the sync goes on', (
    tester,
  ) async {
    await launchApp(tester);
    await logIn();
    accounts.expireAccessTokens();

    await createRecipe('Carbonara');

    expect(onServer(), ['Carbonara']);

    await recipes.closeApp();
    accounts.expireAccessTokens();
    await launchApp(tester, restart: true);
    await createRecipe('Pancakes');
    expect(onServer(), ['Carbonara', 'Pancakes']);
  });

  testWidgets('when the session can no longer be renewed you are logged out '
      'and keep your recipes', (tester) async {
    await launchApp(tester);
    await logIn();
    accounts.expireSessions();

    await createRecipe('Carbonara');

    expect(find.text('Carbonara'), findsOneWidget);
    await account.openSettings();
    expect(account.accountSetting, 'Not logged in');
  });
}
