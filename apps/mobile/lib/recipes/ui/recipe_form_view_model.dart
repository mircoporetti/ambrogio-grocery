import 'dart:developer';

import 'package:flutter/foundation.dart';

import '../application/create_recipe.dart';
import '../application/pick_recipe_photo.dart';
import '../domain/recipe.dart';

class RecipeFormViewModel extends ChangeNotifier {
  RecipeFormViewModel(this._createRecipe, this._pickRecipePhoto);

  final CreateRecipe _createRecipe;
  final PickRecipePhoto _pickRecipePhoto;

  String? _photoPath;
  String? get photoPath => _photoPath;

  bool _saving = false;
  bool get saving => _saving;

  String? _error;
  String? get error => _error;

  Future<void> pickPhoto() async {
    final path = await _pickRecipePhoto();
    if (path == null) return;
    _photoPath = path;
    notifyListeners();
  }

  /// Returns true when the recipe was saved and the form can close.
  Future<bool> save(Recipe recipe) async {
    _saving = true;
    _error = null;
    notifyListeners();
    try {
      await _createRecipe(recipe);
      return true;
    } on Exception catch (e, stackTrace) {
      log('Saving recipe failed', error: e, stackTrace: stackTrace);
      _error = 'Could not save the recipe. Please try again.';
      return false;
    } finally {
      _saving = false;
      notifyListeners();
    }
  }
}
