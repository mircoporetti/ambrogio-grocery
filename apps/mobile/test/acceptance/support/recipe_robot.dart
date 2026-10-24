import 'package:ambrogio_grocery/app.dart';
import 'package:ambrogio_grocery/recipes/domain/photo_picker_port.dart';
import 'package:ambrogio_grocery/recipes/domain/photo_storage_port.dart';
import 'package:ambrogio_grocery/recipes/domain/recipe_storage_port.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'fake_photo_picker_adapter.dart';
import 'fake_photo_storage_adapter.dart';

class RecipeRobot {
  RecipeRobot(this.tester);

  final WidgetTester tester;

  Future<void> launchApp(
    RecipeStoragePort storage, {
    PhotoPickerPort? photoPicker,
    PhotoStoragePort? photoStorage,
  }) async {
    await tester.pumpWidget(
      AmbrogioApp(
        recipeStorage: storage,
        photoPicker: photoPicker ?? FakePhotoPickerAdapter(),
        photoStorage: photoStorage ?? FakePhotoStorageAdapter(),
      ),
    );
    await tester.pumpAndSettle();
  }

  Future<void> deleteOpenRecipe() => _tap(find.byTooltip('Delete recipe'));

  Future<void> confirmDelete() => _tap(find.text('Delete'));

  Future<void> cancelDelete() => _tap(find.text('Cancel'));

  Future<void> addPhoto() => _tap(find.text('Add photo (optional)'));

  Future<void> closeApp() async {
    await tester.pumpWidget(const SizedBox.shrink());
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
