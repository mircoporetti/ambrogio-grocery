import 'dart:convert';

import 'package:ambrogio_grocery/database/app_database.dart';
import 'package:ambrogio_grocery/recipes/data/drift_recipe_storage_adapter.dart';
import 'package:ambrogio_grocery/recipes/domain/photo_id.dart';
import 'package:ambrogio_grocery/recipes/domain/recipe.dart';
import 'package:ambrogio_grocery/recipes/domain/recipe_id.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/account_robot.dart';
import 'support/fake_account_api_adapter.dart';
import 'support/fake_photo_picker_adapter.dart';
import 'support/fake_photo_storage_adapter.dart';
import 'support/fake_photo_sync_api_adapter.dart';
import 'support/fake_recipe_sync_api_adapter.dart';
import 'support/recipe_robot.dart';
import 'support/test_database.dart';
import 'support/test_secure_storage.dart';

const ada = 'ada@example.com';
const password = 'secret-pw';
final carbonaraPhoto = FakePhotoPickerAdapter.bytesOf('carbonara');
final risottoPhoto = utf8.encode('risotto photo');

void main() {
  late FakeAccountApiAdapter accounts;
  late FakeRecipeSyncApiAdapter server;
  late FakePhotoSyncApiAdapter photoServer;
  late FakePhotoStorageAdapter photoFiles;
  late FakePhotoPickerAdapter photoPicker;
  late DriftRecipeStorageAdapter storage;
  late RecipeRobot recipes;
  late AccountRobot account;

  setUp(() {
    accounts = FakeAccountApiAdapter()..givenAccount(ada, password);
    server = FakeRecipeSyncApiAdapter(accounts);
    photoServer = FakePhotoSyncApiAdapter(accounts);
    photoFiles = FakePhotoStorageAdapter();
    photoPicker = FakePhotoPickerAdapter();
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
      photoSyncApi: photoServer,
      photoStorage: photoFiles,
      photoPicker: photoPicker,
      sessionStorage: restart ? reopenedSecureStorage() : emptySecureStorage(),
    );
  }

  Future<void> logIn() async {
    await account.logIn(ada, password);
    await account.goBackWithSystemButton();
  }

  Future<void> createRecipe(String title, {String? photo}) async {
    photoPicker.nextPhoto = photo;
    await recipes.startNewRecipe();
    if (photo != null) await recipes.addPhoto();
    await recipes.enterTitle(title);
    await recipes.enterPortions('2');
    await recipes.addIngredient('Salt', '5', 'g');
    await recipes.save();
  }

  List<int>? shownPhoto(String title) => switch (recipes.photoInList(title)) {
    null => null,
    final path => photoFiles.fileAt(path),
  };

  List<String> titlesOnServer() => [
    for (final recipe in server.recipesOf(ada)) recipe.title,
  ];

  Recipe onServer(String title) =>
      server.recipesOf(ada).singleWhere((r) => r.title == title);

  List<int>? photoOnServer(String title) =>
      photoServer.photoOf(ada, onServer(title).photo!.id);

  group('a photo added on this phone', () {
    testWidgets('is uploaded with its recipe', (tester) async {
      await launchApp(tester);
      await logIn();

      await createRecipe('Carbonara', photo: 'carbonara');

      expect(shownPhoto('Carbonara'), carbonaraPhoto);
      expect(photoOnServer('Carbonara'), carbonaraPhoto);
    });

    testWidgets('before logging in is uploaded at login', (tester) async {
      await launchApp(tester);
      await createRecipe('Carbonara', photo: 'carbonara');
      expect(photoServer.photoCountOf(ada), 0);

      await logIn();

      expect(photoOnServer('Carbonara'), carbonaraPhoto);
    });

    testWidgets(
      'without signal is shown and uploaded when the signal is back',
      (tester) async {
        await launchApp(tester);
        await logIn();
        server.unreachable = true;
        photoServer.unreachable = true;

        await createRecipe('Carbonara', photo: 'carbonara');

        expect(shownPhoto('Carbonara'), carbonaraPhoto);
        expect(titlesOnServer(), isEmpty);

        server.unreachable = false;
        photoServer.unreachable = false;
        await recipes.bringAppToForeground();

        expect(photoOnServer('Carbonara'), carbonaraPhoto);
      },
    );

    testWidgets('keeps its recipe back until it is uploaded, without holding '
        'back the other recipes', (tester) async {
      await launchApp(tester);
      await logIn();
      photoServer.storageDown = true;

      await createRecipe('Carbonara', photo: 'carbonara');
      await createRecipe('Pancakes');

      expect(titlesOnServer(), ['Pancakes']);

      photoServer.storageDown = false;
      await recipes.bringAppToForeground();

      expect(titlesOnServer(), ['Pancakes', 'Carbonara']);
      expect(photoOnServer('Carbonara'), carbonaraPhoto);
    });

    testWidgets('waiting for upload survives closing the app', (tester) async {
      final file = newDatabaseFile();
      final firstRun = openFileDatabase(file);
      await launchApp(tester, database: firstRun);
      await logIn();
      photoServer.unreachable = true;
      await createRecipe('Carbonara', photo: 'carbonara');
      await recipes.closeApp();
      await firstRun.close();

      photoServer.unreachable = false;
      final secondRun = openFileDatabase(file);
      addTearDown(secondRun.close);
      await launchApp(tester, database: secondRun, restart: true);

      expect(photoOnServer('Carbonara'), carbonaraPhoto);
    });

    testWidgets('is uploaded only once', (tester) async {
      await launchApp(tester);
      await logIn();
      await createRecipe('Carbonara', photo: 'carbonara');

      await recipes.openRecipe('Carbonara');
      await recipes.editOpenRecipe();
      await recipes.enterTitle('Carbonara classica');
      await recipes.save();
      await recipes.goBack();
      await recipes.bringAppToForeground();

      expect(photoServer.uploadAttempts, 1);
    });

    testWidgets('that the server refuses still lets its recipe sync', (
      tester,
    ) async {
      await launchApp(tester);
      await logIn();
      photoServer.rejectPhotos = true;

      await createRecipe('Carbonara', photo: 'carbonara');
      await recipes.bringAppToForeground();

      expect(titlesOnServer(), ['Carbonara']);
      expect(photoServer.uploadAttempts, 1);
      expect(shownPhoto('Carbonara'), carbonaraPhoto);
    });
  });

  group('a photo added on another phone', () {
    late RecipeId risottoId;
    late PhotoId risottoPhotoId;

    setUp(() {
      risottoId = RecipeId.generate();
      risottoPhotoId = PhotoId.generate();
      server.givenRecipe(ada, 'Risotto', id: risottoId, photo: risottoPhotoId);
    });

    testWidgets('is downloaded with its recipe', (tester) async {
      photoServer.givenPhoto(ada, risottoPhotoId, risottoPhoto);
      await launchApp(tester);

      await logIn();

      expect(shownPhoto('Risotto'), risottoPhoto);
    });

    testWidgets('stays on the phone without signal, also after a restart', (
      tester,
    ) async {
      photoServer.givenPhoto(ada, risottoPhotoId, risottoPhoto);
      final file = newDatabaseFile();
      final firstRun = openFileDatabase(file);
      await launchApp(tester, database: firstRun);
      await logIn();
      await recipes.closeApp();
      await firstRun.close();

      server.unreachable = true;
      photoServer.unreachable = true;
      final secondRun = openFileDatabase(file);
      addTearDown(secondRun.close);
      await launchApp(tester, database: secondRun, restart: true);

      expect(shownPhoto('Risotto'), risottoPhoto);
    });

    testWidgets('not uploaded yet shows the recipe without it, until a later '
        'sync downloads it', (tester) async {
      await launchApp(tester);
      await logIn();

      expect(find.text('Risotto'), findsOneWidget);
      expect(recipes.photoInList('Risotto'), isNull);

      photoServer.givenPhoto(ada, risottoPhotoId, risottoPhoto);
      await recipes.bringAppToForeground();

      expect(shownPhoto('Risotto'), risottoPhoto);
    });

    testWidgets('that fails to download is tried again at the next sync', (
      tester,
    ) async {
      photoServer.givenPhoto(ada, risottoPhotoId, risottoPhoto);
      photoServer.storageDown = true;
      await launchApp(tester);
      await logIn();

      expect(find.text('Risotto'), findsOneWidget);
      expect(recipes.photoInList('Risotto'), isNull);

      photoServer.storageDown = false;
      await recipes.bringAppToForeground();

      expect(shownPhoto('Risotto'), risottoPhoto);
    });

    testWidgets('replaced there replaces it here', (tester) async {
      photoServer.givenPhoto(ada, risottoPhotoId, risottoPhoto);
      await launchApp(tester);
      await logIn();
      final oldPath = recipes.photoInList('Risotto')!;

      final newPhotoId = PhotoId.generate();
      final newPhoto = utf8.encode('new risotto photo');
      photoServer.givenPhoto(ada, newPhotoId, newPhoto);
      server.givenRecipe(ada, 'Risotto', id: risottoId, photo: newPhotoId);
      await recipes.bringAppToForeground();

      expect(shownPhoto('Risotto'), newPhoto);
      expect(photoFiles.fileAt(oldPath), isNull);
    });

    testWidgets('is removed from this phone with its recipe', (tester) async {
      photoServer.givenPhoto(ada, risottoPhotoId, risottoPhoto);
      await launchApp(tester);
      await logIn();
      expect(shownPhoto('Risotto'), risottoPhoto);

      server.givenDeletion(ada, risottoId);
      await recipes.bringAppToForeground();

      expect(find.text('Risotto'), findsNothing);
      expect(photoFiles.isEmpty, isTrue);
    });

    testWidgets('is not kept when its recipe is deleted while downloading', (
      tester,
    ) async {
      photoServer.givenPhoto(ada, risottoPhotoId, risottoPhoto);
      photoServer.whileDownloading = () => storage.delete(risottoId);
      await launchApp(tester);

      await logIn();

      expect(find.text('Risotto'), findsNothing);
      expect(photoFiles.isEmpty, isTrue);
    });
  });

  testWidgets('logging out removes the photos from the phone', (tester) async {
    final photo = PhotoId.generate();
    server.givenRecipe(ada, 'Risotto', photo: photo);
    photoServer.givenPhoto(ada, photo, risottoPhoto);
    await launchApp(tester);
    await logIn();
    await createRecipe('Carbonara', photo: 'carbonara');

    await account.openSettings();
    await account.logOut();

    expect(photoFiles.isEmpty, isTrue);
  });
}
