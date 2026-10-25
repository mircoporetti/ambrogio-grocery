import 'dart:developer';

import 'package:flutter/foundation.dart';

import '../application/create_recipe.dart';
import '../application/pick_recipe_photo.dart';
import '../application/update_recipe.dart';
import '../domain/recipe.dart';

class RecipeFormViewModel extends ChangeNotifier {
  RecipeFormViewModel.create(CreateRecipe createRecipe, this._pickRecipePhoto)
    : _submit = createRecipe.call,
      initial = null;

  RecipeFormViewModel.edit(
    UpdateRecipe updateRecipe,
    this._pickRecipePhoto,
    Recipe this.initial,
  ) : _submit = updateRecipe.call,
      _photoPath = initial.photoPath;

  final Future<void> Function(Recipe) _submit;
  final PickRecipePhoto _pickRecipePhoto;

  final Recipe? initial;

  bool get isEditing => initial != null;

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

  Future<bool> save(Recipe recipe) async {
    _saving = true;
    _error = null;
    notifyListeners();
    try {
      await _submit(recipe);
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
