import 'dart:async';

import 'package:flutter/foundation.dart';

import '../application/watch_recipes.dart';
import '../domain/recipe.dart';

class RecipeListViewModel extends ChangeNotifier {
  RecipeListViewModel(WatchRecipes watchRecipes) {
    _subscription = watchRecipes().listen((recipes) {
      _recipes = recipes;
      _loading = false;
      notifyListeners();
    });
  }

  late final StreamSubscription<List<Recipe>> _subscription;

  List<Recipe> _recipes = const [];
  List<Recipe> get recipes => _recipes;

  bool _loading = true;
  bool get loading => _loading;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
