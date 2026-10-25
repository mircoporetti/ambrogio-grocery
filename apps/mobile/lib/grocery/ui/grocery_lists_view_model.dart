import 'dart:async';
import 'dart:developer';

import 'package:flutter/foundation.dart';

import '../application/delete_grocery_list.dart';
import '../application/get_current_week.dart';
import '../application/watch_upcoming_grocery_lists.dart';
import '../domain/grocery_list.dart';
import '../domain/week.dart';

class GroceryListsViewModel extends ChangeNotifier {
  GroceryListsViewModel(
    WatchUpcomingGroceryLists watchUpcomingGroceryLists,
    GetCurrentWeek getCurrentWeek,
    this._deleteGroceryList,
  ) : currentWeek = getCurrentWeek() {
    _subscription = watchUpcomingGroceryLists().listen((lists) {
      _lists = lists;
      _loading = false;
      notifyListeners();
    });
  }

  final DeleteGroceryList _deleteGroceryList;
  final Week currentWeek;
  late final StreamSubscription<List<GroceryList>> _subscription;

  List<GroceryList> _lists = const [];
  List<GroceryList> get lists => _lists;

  bool _loading = true;
  bool get loading => _loading;

  String? _error;
  String? get error => _error;

  Future<bool> delete(GroceryList list) async {
    _error = null;
    notifyListeners();
    try {
      await _deleteGroceryList(list.id);
      _lists = [..._lists.where((l) => l.id != list.id)];
      return true;
    } on Exception catch (e, stackTrace) {
      log('Deleting grocery list failed', error: e, stackTrace: stackTrace);
      _error = 'Could not delete the grocery list. Please try again.';
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
