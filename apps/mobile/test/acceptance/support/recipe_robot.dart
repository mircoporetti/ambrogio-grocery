import 'package:ambrogio_grocery/app.dart';
import 'package:ambrogio_grocery/recipes/domain/photo_picker_port.dart';
import 'package:ambrogio_grocery/recipes/domain/recipe_storage_port.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'fake_photo_picker_adapter.dart';

/// Drives the app the way a user would, so acceptance tests read as
/// requirements instead of widget plumbing.
class RecipeRobot {
  RecipeRobot(this.tester);

  final WidgetTester tester;

  /// Tests never open the real device gallery.
  Future<void> launchApp(
    RecipeStoragePort storage, {
    PhotoPickerPort? photoPicker,
  }) async {
    await tester.pumpWidget(
      AmbrogioApp(
        recipeStorage: storage,
        photoPicker: photoPicker ?? FakePhotoPickerAdapter(),
      ),
    );
    await tester.pumpAndSettle();
  }

  Future<void> addPhoto() => _tap(find.text('Add photo (optional)'));

  Future<void> closeApp() async {
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpAndSettle();
  }

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
