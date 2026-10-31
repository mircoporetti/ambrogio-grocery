import 'package:ambrogio_grocery/account/domain/account_api_port.dart';
import 'package:ambrogio_grocery/account/domain/log_in_prompt_port.dart';
import 'package:ambrogio_grocery/account/domain/session_storage_port.dart';
import 'package:ambrogio_grocery/app.dart';
import 'package:ambrogio_grocery/grocery/data/drift_grocery_list_storage_adapter.dart';
import 'package:ambrogio_grocery/grocery/domain/clock_port.dart';
import 'package:ambrogio_grocery/grocery/domain/grocery_list_storage_port.dart';
import 'package:ambrogio_grocery/grocery/domain/grocery_list_sync_api_port.dart';
import 'package:ambrogio_grocery/grocery/domain/grocery_list_sync_storage_port.dart';
import 'package:ambrogio_grocery/install/domain/home_screen_port.dart';
import 'package:ambrogio_grocery/recipes/domain/photo_picker_port.dart';
import 'package:ambrogio_grocery/recipes/domain/photo_storage_port.dart';
import 'package:ambrogio_grocery/recipes/domain/photo_sync_api_port.dart';
import 'package:ambrogio_grocery/recipes/data/drift_recipe_storage_adapter.dart';
import 'package:ambrogio_grocery/recipes/domain/recipe_storage_port.dart';
import 'package:ambrogio_grocery/recipes/domain/recipe_sync_api_port.dart';
import 'package:ambrogio_grocery/recipes/domain/recipe_sync_storage_port.dart';
import 'package:ambrogio_grocery/settings/data/shared_preferences_language_preference_adapter.dart';
import 'package:ambrogio_grocery/settings/domain/language_preference_port.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'fake_account_api_adapter.dart';
import 'fake_grocery_list_sync_api_adapter.dart';
import 'fake_home_screen_adapter.dart';
import 'fake_photo_picker_adapter.dart';
import 'fake_recipe_sync_api_adapter.dart';
import 'fake_photo_storage_adapter.dart';
import 'fake_photo_sync_api_adapter.dart';
import 'fixed_clock_adapter.dart';
import 'test_database.dart';
import 'test_preferences.dart';
import 'test_secure_storage.dart';

class RecipeRobot {
  RecipeRobot(this.tester);

  final WidgetTester tester;

  Future<void> launchApp(
    RecipeStoragePort storage, {
    PhotoPickerPort? photoPicker,
    PhotoStoragePort? photoStorage,
    GroceryListStoragePort? groceryListStorage,
    ClockPort? clock,
    LanguagePreferencePort? languagePreference,
    AccountApiPort? accountApi,
    SessionStoragePort? sessionStorage,
    LogInPromptPort? logInPrompt,
    RecipeSyncApiPort? recipeSyncApi,
    PhotoSyncApiPort? photoSyncApi,
    GroceryListSyncApiPort? groceryListSyncApi,
    HomeScreenPort? homeScreen,
  }) async {
    final api = accountApi ?? FakeAccountApiAdapter();
    final fakeAccounts = api is FakeAccountApiAdapter
        ? api
        : FakeAccountApiAdapter();
    final lists =
        groceryListStorage ??
        DriftGroceryListStorageAdapter(openInMemoryDatabase());
    await tester.pumpWidget(
      AmbrogioApp(
        recipeStorage: storage,
        recipeSyncStorage: switch (storage) {
          final RecipeSyncStoragePort sync => sync,
          _ => DriftRecipeStorageAdapter(
            openInMemoryDatabase(),
            documentsDir: testDocumentsDir,
          ),
        },
        recipeSyncApi: recipeSyncApi ?? FakeRecipeSyncApiAdapter(fakeAccounts),
        photoSyncApi: photoSyncApi ?? FakePhotoSyncApiAdapter(fakeAccounts),
        groceryListStorage: lists,
        // Tests that wrap the storage to make it fail don't sync.
        groceryListSyncStorage: switch (lists) {
          final GroceryListSyncStoragePort sync => sync,
          _ => DriftGroceryListStorageAdapter(openInMemoryDatabase()),
        },
        groceryListSyncApi:
            groceryListSyncApi ?? FakeGroceryListSyncApiAdapter(fakeAccounts),
        clock: clock ?? FixedClockAdapter(today),
        photoPicker: photoPicker ?? FakePhotoPickerAdapter(),
        photoStorage: photoStorage ?? FakePhotoStorageAdapter(),
        languagePreference:
            languagePreference ??
            SharedPreferencesLanguagePreferenceAdapter(inMemoryPreferences()),
        accountApi: api,
        sessionStorage: sessionStorage ?? emptySecureStorage(),
        logInPrompt: logInPrompt ?? await answeredLogInPrompt(),
        homeScreen:
            homeScreen ?? FakeHomeScreenAdapter(inIphoneBrowserTab: false),
      ),
    );
    await tester.pumpAndSettle();
  }

  Future<void> deleteOpenRecipe() => _tap(find.byTooltip('Delete recipe'));

  Future<void> editOpenRecipe() => _tap(find.byTooltip('Edit recipe'));

  Future<void> removeIngredient(String name) =>
      _tap(find.byTooltip('Remove $name'));

  Future<void> removeCategory(String name) =>
      _tap(find.byTooltip('Remove $name'));

  String? photoInList(String title) {
    final avatar = tester.widget<CircleAvatar>(
      find.descendant(
        of: find.widgetWithText(ListTile, title),
        matching: find.byType(CircleAvatar),
      ),
    );
    return switch (avatar.backgroundImage) {
      final FileImage image => image.file.path,
      _ => null,
    };
  }

  Future<void> changePhoto() => _tap(find.bySemanticsLabel('Change photo'));

  String fieldText(String label) => tester
      .widget<TextField>(find.widgetWithText(TextField, label))
      .controller!
      .text;

  Future<void> swipeToDelete(String title) async {
    await tester.fling(
      find.ancestor(of: find.text(title), matching: find.byType(Dismissible)),
      const Offset(-500, 0),
      1000,
    );
    await tester.pumpAndSettle();
  }

  Future<void> confirmDelete() => _tap(find.text('Delete'));

  Future<void> cancelDelete() => _tap(find.text('Cancel'));

  Future<void> addPhoto() => _tap(find.text('Add photo (optional)'));

  Future<void> closeApp() async {
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpAndSettle();
  }

  Future<void> bringAppToForeground() async {
    for (final state in [
      AppLifecycleState.inactive,
      AppLifecycleState.hidden,
      AppLifecycleState.paused,
      AppLifecycleState.hidden,
      AppLifecycleState.inactive,
      AppLifecycleState.resumed,
    ]) {
      tester.binding.handleAppLifecycleStateChanged(state);
    }
    await tester.pumpAndSettle();
  }

  Future<void> openRecipe(String title) => _tap(find.text(title));

  Future<void> goBack() => _tap(find.byTooltip('Back'));

  Future<void> startNewRecipe() async {
    await tester.tap(find.byTooltip('New recipe'));
    await tester.pumpAndSettle();
  }

  Future<void> enterTitle(String title) => _enter('Title', title);

  Future<void> enterPortions(String portions) => _enter('Portions', portions);

  Future<void> enterProcedure(String procedure) =>
      _enter('Procedure (optional)', procedure);

  Future<void> addIngredient(String name, String quantity, String unit) async {
    await _enter('Ingredient', name);
    await _enter('Quantity', quantity);
    await _tap(find.text(unit));
    await _tap(find.text('Add ingredient'));
  }

  Future<void> addCategory(String category) async {
    await _enter('Category', category);
    await _tap(find.text('Add category'));
  }

  Future<void> save() async {
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();
  }

  Future<void> _enter(String label, String text) async {
    final field = find.widgetWithText(TextFormField, label);
    await tester.ensureVisible(field);
    await tester.enterText(field, text);
    await tester.pumpAndSettle();
  }

  Future<void> _tap(Finder finder) async {
    await tester.ensureVisible(finder);
    await tester.tap(finder);
    await tester.pumpAndSettle();
  }
}
