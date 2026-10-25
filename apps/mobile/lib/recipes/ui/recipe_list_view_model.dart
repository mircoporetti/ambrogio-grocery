import 'dart:async';
import 'dart:developer';

import 'package:flutter/foundation.dart';

import '../application/delete_recipe.dart';
import '../application/watch_recipes.dart';
import '../domain/recipe.dart';

class RecipeListViewModel extends ChangeNotifier {
  RecipeListViewModel(WatchRecipes watchRecipes, this._deleteRecipe) {
    _subscription = watchRecipes().listen((recipes) {
      _recipes = recipes;
      _loading = false;
      notifyListeners();
    });
  }

  final DeleteRecipe _deleteRecipe;
  late final StreamSubscription<List<Recipe>> _subscription;

  List<Recipe> _recipes = const [];
  List<Recipe> get recipes => _recipes;

  bool _loading = true;
  bool get loading => _loading;

  String? _error;
  String? get error => _error;

  Future<bool> delete(Recipe recipe) async {
    _error = null;
    notifyListeners();
    try {
      await _deleteRecipe(recipe);
      _recipes = [..._recipes.where((r) => r.id != recipe.id)];
      return true;
    } on Exception catch (e, stackTrace) {
      log('Deleting recipe failed', error: e, stackTrace: stackTrace);
      _error = 'Could not delete the recipe. Please try again.';
      return false;
    } finally {
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
