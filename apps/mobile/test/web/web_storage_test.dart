@TestOn('browser')
library;

import 'dart:async';
import 'dart:convert';

import 'package:ambrogio_grocery/database/app_database.dart';
import 'package:ambrogio_grocery/recipes/data/drift_recipe_storage_adapter.dart';
import 'package:ambrogio_grocery/recipes/data/photo_storage_on_device.dart';
import 'package:ambrogio_grocery/recipes/domain/ingredient.dart';
import 'package:ambrogio_grocery/recipes/domain/photo.dart';
import 'package:ambrogio_grocery/recipes/domain/photo_file.dart';
import 'package:ambrogio_grocery/recipes/domain/photo_id.dart';
import 'package:ambrogio_grocery/recipes/domain/recipe.dart';
import 'package:ambrogio_grocery/recipes/ui/photo_image.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:uuid/uuid.dart';

// The acceptance tests run on the VM with the device adapters; this checks
// the browser ones: SQLite on WebAssembly and photos in IndexedDB.
void main() {
  final onePixelPng = base64Decode(
    'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR4nGNg+M/wHwAEAQH/'
    'cetH5QAAAABJRU5ErkJggg==',
  );

  Recipe carbonara(Photo photo) => Recipe(
    title: 'Carbonara',
    portions: 4,
    ingredients: [
      Ingredient(name: 'Spaghetti', quantity: 320, unit: MeasureUnit.grams),
    ],
    photo: photo,
  );

  test('recipes and photos are still there after the page reloads', () async {
    final name = 'test_${const Uuid().v4()}';

    final firstLoad = await photoStorageOnDevice();
    final firstDb = AppDatabase.onDevice(name: name);
    final id = PhotoId.generate();
    final path = await firstLoad.photoStorage.save(
      id,
      PhotoFile(bytes: onePixelPng, contentType: 'image/png'),
    );
    await DriftRecipeStorageAdapter(
      firstDb,
      documentsDir: firstLoad.documentsDir,
    ).save(carbonara(Photo(id: id, path: path)));
    await firstDb.close();

    final secondLoad = await photoStorageOnDevice();
    final secondDb = AppDatabase.onDevice(name: name);
    addTearDown(secondDb.close);
    final recipe = (await DriftRecipeStorageAdapter(
      secondDb,
      documentsDir: secondLoad.documentsDir,
    ).findAll()).single;

    expect(recipe.title, 'Carbonara');
    expect(recipe.photo?.path, path);
    final photo = await secondLoad.photoStorage.read(recipe.photo!);
    expect(photo?.bytes, onePixelPng);
    expect(photo?.contentType, 'image/png');
  });

  test('a deleted photo is gone', () async {
    final photos = (await photoStorageOnDevice()).photoStorage;
    final id = PhotoId.generate();
    final path = await photos.save(
      id,
      PhotoFile(bytes: utf8.encode('jpeg'), contentType: 'image/jpeg'),
    );

    await photos.delete(Photo(id: id, path: path));

    expect(await photos.read(Photo(id: id, path: path)), isNull);
  });

  testWidgets('pages show the photo stored in the browser', (tester) async {
    final photos = (await photoStorageOnDevice()).photoStorage;
    final path = await tester.runAsync(
      () => photos.save(
        PhotoId.generate(),
        PhotoFile(bytes: onePixelPng, contentType: 'image/png'),
      ),
    );

    final image = await tester.runAsync(() async {
      final loaded = Completer<ImageInfo>();
      photoImage(path!)
          .resolve(ImageConfiguration.empty)
          .addListener(
            ImageStreamListener(
              (info, _) => loaded.complete(info),
              onError: loaded.completeError,
            ),
          );
      return loaded.future;
    });

    expect(image!.image.width, 1);
  });
}
