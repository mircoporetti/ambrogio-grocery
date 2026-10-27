import 'package:ambrogio_grocery/database/app_database.dart';
import 'package:ambrogio_grocery/grocery/data/drift_grocery_list_storage_adapter.dart';
import 'package:ambrogio_grocery/grocery/domain/grocery_list.dart';
import 'package:ambrogio_grocery/grocery/domain/week.dart';
import 'package:ambrogio_grocery/recipes/data/drift_recipe_storage_adapter.dart';
import 'package:ambrogio_grocery/recipes/domain/ingredient.dart';
import 'package:ambrogio_grocery/recipes/domain/recipe.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/account_robot.dart';
import 'support/fake_account_api_adapter.dart';
import 'support/fake_grocery_list_sync_api_adapter.dart';
import 'support/fake_recipe_sync_api_adapter.dart';
import 'support/grocery_robot.dart';
import 'support/recipe_robot.dart';
import 'support/test_database.dart';
import 'support/test_secure_storage.dart';

const ada = 'ada@example.com';
const password = 'secret-pw';
const thisWeek = '19 – 25 Oct';

void main() {
  final week = Week.containing(today);
  late AppDatabase db;
  late FakeAccountApiAdapter accounts;
  late FakeGroceryListSyncApiAdapter server;
  late DriftGroceryListStorageAdapter lists;
  late RecipeRobot app;
  late GroceryRobot grocery;
  late AccountRobot account;

  Ingredient grams(String name, double quantity) =>
      Ingredient(name: name, quantity: quantity, unit: MeasureUnit.grams);

  final carbonara = Recipe(
    title: 'Carbonara',
    portions: 2,
    ingredients: [grams('Guanciale', 150), grams('Spaghetti', 320)],
  );
  final risotto = Recipe(
    title: 'Risotto',
    portions: 2,
    ingredients: [grams('Rice', 300)],
  );

  setUp(() {
    db = openInMemoryDatabase();
    accounts = FakeAccountApiAdapter()..givenAccount(ada, password);
    server = FakeGroceryListSyncApiAdapter(accounts);
  });

  Future<void> launchApp(WidgetTester tester, {bool restart = false}) async {
    final recipes = DriftRecipeStorageAdapter(
      db,
      documentsDir: testDocumentsDir,
    );
    if (!restart) await recipes.save(carbonara);
    lists = DriftGroceryListStorageAdapter(db);
    app = RecipeRobot(tester);
    grocery = GroceryRobot(tester);
    account = AccountRobot(tester);
    await app.launchApp(
      recipes,
      groceryListStorage: lists,
      accountApi: accounts,
      recipeSyncApi: FakeRecipeSyncApiAdapter(accounts),
      groceryListSyncApi: server,
      sessionStorage: restart ? reopenedSecureStorage() : emptySecureStorage(),
    );
  }

  Future<void> logIn() async {
    await account.logIn(ada, password);
    await account.goBackWithSystemButton();
  }

  Future<void> planCarbonara() async {
    await grocery.startPlanningWeek();
    await grocery.cook();
    await grocery.createGroceryList();
  }

  Map<String, bool> ticksOnServer() => {
    for (final item in server.listOf(ada, week)?.items ?? const [])
      item.ingredient.name: item.ticked,
  };

  testWidgets('lists made before logging in are uploaded at login', (
    tester,
  ) async {
    await launchApp(tester);
    await planCarbonara();
    await grocery.tick('Guanciale');
    await grocery.goBack();
    await grocery.goBack();
    expect(server.listOf(ada, week), isNull);

    await logIn();

    expect(server.listOf(ada, week)!.recipes, ['Carbonara']);
    expect(ticksOnServer(), {'Guanciale': true, 'Spaghetti': false});
  });

  testWidgets('planning, ticking and deleting a list are uploaded', (
    tester,
  ) async {
    await launchApp(tester);
    await logIn();

    await planCarbonara();
    expect(ticksOnServer(), {'Guanciale': false, 'Spaghetti': false});

    await grocery.tick('Spaghetti');
    expect(ticksOnServer(), {'Guanciale': false, 'Spaghetti': true});

    await grocery.untick('Spaghetti');
    expect(ticksOnServer(), {'Guanciale': false, 'Spaghetti': false});

    await grocery.deleteOpenGroceryList();
    await grocery.confirmDelete();
    expect(server.listOf(ada, week), isNull);
  });

  testWidgets('ticks made on another phone show up when you come back to '
      'the app', (tester) async {
    await launchApp(tester);
    await logIn();
    await planCarbonara();

    server.tickOnOtherPhone(ada, week, 'Spaghetti');
    expect(grocery.isTicked('Spaghetti'), isFalse);

    await app.bringAppToForeground();

    expect(grocery.isTicked('Spaghetti'), isTrue);
    expect(grocery.isTicked('Guanciale'), isFalse);
  });

  testWidgets('shopping together: ticks from both phones are all kept', (
    tester,
  ) async {
    await launchApp(tester);
    await logIn();
    await planCarbonara();
    server.unreachable = true;

    await grocery.tick('Guanciale');
    server.tickOnOtherPhone(ada, week, 'Spaghetti');
    server.unreachable = false;
    await app.bringAppToForeground();

    expect(grocery.isTicked('Guanciale'), isTrue);
    expect(grocery.isTicked('Spaghetti'), isTrue);
    expect(ticksOnServer(), {'Guanciale': true, 'Spaghetti': true});
  });

  testWidgets('the same item ticked on one phone and unticked later on the '
      'other ends up unticked', (tester) async {
    await launchApp(tester);
    await logIn();
    await planCarbonara();
    server.unreachable = true;

    await grocery.tick('Guanciale');
    server.tickOnOtherPhone(ada, week, 'Guanciale', ticked: false);
    server.unreachable = false;
    await app.bringAppToForeground();

    expect(grocery.isTicked('Guanciale'), isFalse);
    expect(ticksOnServer()['Guanciale'], isFalse);
  });

  testWidgets('a week planned again on another phone replaces the list', (
    tester,
  ) async {
    await launchApp(tester);
    await logIn();
    await planCarbonara();
    await grocery.tick('Guanciale');

    server.planOnOtherPhone(ada, GroceryList.plan(week, [risotto]));
    await app.bringAppToForeground();

    expect(grocery.groceryList, ['Rice 300 g']);
    expect(grocery.isTicked('Rice'), isFalse);
  });

  testWidgets('ticking at the supermarket without signal works and is '
      'uploaded when the signal is back', (tester) async {
    await launchApp(tester);
    await logIn();
    await planCarbonara();
    server.unreachable = true;

    await grocery.tick('Guanciale');
    await grocery.tick('Spaghetti');

    expect(grocery.isTicked('Guanciale'), isTrue);
    expect(grocery.isTicked('Spaghetti'), isTrue);
    expect(ticksOnServer(), {'Guanciale': false, 'Spaghetti': false});

    server.unreachable = false;
    await app.bringAppToForeground();

    expect(ticksOnServer(), {'Guanciale': true, 'Spaghetti': true});
  });

  testWidgets('logging out removes the lists from the phone and logging in '
      'brings them back with their ticks', (tester) async {
    await launchApp(tester);
    await logIn();
    await planCarbonara();
    await grocery.tick('Guanciale');
    await grocery.goBack();
    await grocery.goBack();

    await account.openSettings();
    await account.logOut();
    await account.goBackWithSystemButton();

    expect(await lists.findAll(), isEmpty);

    await logIn();
    await grocery.openGroceryLists();
    await grocery.openGroceryList(thisWeek);

    expect(grocery.groceryList, ['Guanciale 150 g', 'Spaghetti 320 g']);
    expect(grocery.isTicked('Guanciale'), isTrue);
  });

  testWidgets('logging out with ticks not uploaded yet asks first', (
    tester,
  ) async {
    await launchApp(tester);
    await logIn();
    await planCarbonara();
    server.unreachable = true;
    await grocery.tick('Guanciale');
    await grocery.goBack();
    await grocery.goBack();
    await account.openSettings();

    await account.logOut();

    expect(account.isWarnedAboutUnsyncedChanges, isTrue);
    await account.stayLoggedIn();
    expect(account.accountSetting, ada);
  });
}
