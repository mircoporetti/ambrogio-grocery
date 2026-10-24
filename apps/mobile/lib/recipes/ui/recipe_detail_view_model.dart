import 'dart:async';

import 'package:flutter/foundation.dart';

import '../application/watch_recipe.dart';
import '../domain/recipe.dart';
import '../domain/recipe_id.dart';

class RecipeDetailViewModel extends ChangeNotifier {
  RecipeDetailViewModel(WatchRecipe watchRecipe, RecipeId id) {
    _subscription = watchRecipe(id).listen((recipe) {
      _recipe = recipe;
      _loading = false;
      notifyListeners();
    });
  }

  late final StreamSubscription<Recipe?> _subscription;

  Recipe? _recipe;
  Recipe? get recipe => _recipe;

  bool _loading = true;
  bool get loading => _loading;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
