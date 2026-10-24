import 'dart:async';
import 'dart:developer';

import 'package:flutter/foundation.dart';

import '../application/delete_recipe.dart';
import '../application/watch_recipe.dart';
import '../domain/recipe.dart';
import '../domain/recipe_id.dart';

class RecipeDetailViewModel extends ChangeNotifier {
  RecipeDetailViewModel(
    WatchRecipe watchRecipe,
    this._deleteRecipe,
    RecipeId id,
  ) {
    _subscription = watchRecipe(id).listen((recipe) {
      _recipe = recipe;
      _loading = false;
      notifyListeners();
    });
  }

  final DeleteRecipe _deleteRecipe;
  late final StreamSubscription<Recipe?> _subscription;

  Recipe? _recipe;
  Recipe? get recipe => _recipe;

  bool _loading = true;
  bool get loading => _loading;

  bool _deleting = false;
  bool get deleting => _deleting;

  String? _error;
  String? get error => _error;

  /// Returns true when the recipe was deleted and the page can close.
  Future<bool> delete() async {
    final recipe = _recipe;
    if (recipe == null) return false;
    _deleting = true;
    _error = null;
    notifyListeners();
    try {
      await _deleteRecipe(recipe);
      return true;
    } on Exception catch (e, stackTrace) {
      log('Deleting recipe failed', error: e, stackTrace: stackTrace);
      _error = 'Could not delete the recipe. Please try again.';
      return false;
    } finally {
      _deleting = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
