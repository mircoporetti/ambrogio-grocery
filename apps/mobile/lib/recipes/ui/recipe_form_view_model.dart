import 'dart:developer';

import 'package:flutter/foundation.dart';

import '../application/create_recipe.dart';
import '../application/pick_recipe_photo.dart';
import '../application/update_recipe.dart';
import '../domain/photo.dart';
import '../domain/recipe.dart';
import 'recipe_error.dart';

class RecipeFormViewModel extends ChangeNotifier {
  RecipeFormViewModel.create(CreateRecipe createRecipe, this._pickRecipePhoto)
    : _submit = createRecipe.call,
      initial = null;

  RecipeFormViewModel.edit(
    UpdateRecipe updateRecipe,
    this._pickRecipePhoto,
    Recipe this.initial,
  ) : _submit = updateRecipe.call,
      _photo = initial.photo;

  final Future<void> Function(Recipe) _submit;
  final PickRecipePhoto _pickRecipePhoto;

  final Recipe? initial;

  bool get isEditing => initial != null;

  Photo? _photo;
  Photo? get photo => _photo;

  bool _saving = false;
  bool get saving => _saving;

  RecipeError? _error;
  RecipeError? get error => _error;

  Future<void> pickPhoto() async {
    final photo = await _pickRecipePhoto();
    if (photo == null) return;
    _photo = photo;
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
      _error = RecipeError.saveFailed;
      return false;
    } finally {
      _saving = false;
      notifyListeners();
    }
  }
}
