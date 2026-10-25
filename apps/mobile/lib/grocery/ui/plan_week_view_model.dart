import 'dart:developer';

import 'package:flutter/foundation.dart';

import '../../recipes/application/list_recipes.dart';
import '../../recipes/domain/recipe.dart';
import '../application/create_grocery_list.dart';
import '../application/find_grocery_list.dart';
import '../application/get_current_week.dart';
import '../domain/week.dart';

class PlanWeekViewModel extends ChangeNotifier {
  PlanWeekViewModel(
    ListRecipes listRecipes,
    this._createGroceryList,
    this._findGroceryList,
    GetCurrentWeek getCurrentWeek,
  ) : _currentWeek = getCurrentWeek() {
    _week = _currentWeek;
    listRecipes().then((recipes) {
      if (_disposed) return;
      _recipes = recipes;
      _loading = false;
      notifyListeners();
    });
  }

  final CreateGroceryList _createGroceryList;
  final FindGroceryList _findGroceryList;
  final Week _currentWeek;
  bool _disposed = false;

  late Week _week;
  Week get week => _week;

  bool get canChooseEarlierWeek => !_week.previous.isBefore(_currentWeek);

  List<Recipe> _recipes = const [];
  List<Recipe> get recipes => _recipes;

  bool _loading = true;
  bool get loading => _loading;

  int _index = 0;
  int get position => _index + 1;

  Recipe? get current => _index < _recipes.length ? _recipes[_index] : null;

  final List<Recipe> _chosen = [];
  int get chosenCount => _chosen.length;

  bool _saving = false;
  bool get saving => _saving;

  String? _error;
  String? get error => _error;

  bool get canCreateGroceryList => _chosen.isNotEmpty && !_saving;

  void earlierWeek() {
    if (!canChooseEarlierWeek) return;
    _week = _week.previous;
    notifyListeners();
  }

  void laterWeek() {
    _week = _week.next;
    notifyListeners();
  }

  void cook() {
    final recipe = current;
    if (recipe == null) return;
    _chosen.add(recipe);
    _next();
  }

  void skip() {
    if (current == null) return;
    _next();
  }

  void _next() {
    _index++;
    notifyListeners();
  }

  Future<bool> replacesList() async {
    try {
      return await _findGroceryList(_week) != null;
    } on Exception catch (e, stackTrace) {
      log('Looking up grocery list failed', error: e, stackTrace: stackTrace);
      return false;
    }
  }

  Future<bool> createGroceryList() async {
    if (!canCreateGroceryList) return false;
    _saving = true;
    _error = null;
    notifyListeners();
    try {
      await _createGroceryList(_week, _chosen);
      return true;
    } on Exception catch (e, stackTrace) {
      log('Saving grocery list failed', error: e, stackTrace: stackTrace);
      _error = 'Could not save the grocery list. Please try again.';
      return false;
    } finally {
      _saving = false;
      if (!_disposed) notifyListeners();
    }
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
