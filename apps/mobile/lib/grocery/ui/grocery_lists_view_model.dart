import 'dart:async';

import 'package:flutter/foundation.dart';

import '../application/get_current_week.dart';
import '../application/watch_upcoming_grocery_lists.dart';
import '../domain/grocery_list.dart';
import '../domain/week.dart';

class GroceryListsViewModel extends ChangeNotifier {
  GroceryListsViewModel(
    WatchUpcomingGroceryLists watchUpcomingGroceryLists,
    GetCurrentWeek getCurrentWeek,
  ) : currentWeek = getCurrentWeek() {
    _subscription = watchUpcomingGroceryLists().listen((lists) {
      _lists = lists;
      _loading = false;
      notifyListeners();
    });
  }

  final Week currentWeek;
  late final StreamSubscription<List<GroceryList>> _subscription;

  List<GroceryList> _lists = const [];
  List<GroceryList> get lists => _lists;

  bool _loading = true;
  bool get loading => _loading;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
