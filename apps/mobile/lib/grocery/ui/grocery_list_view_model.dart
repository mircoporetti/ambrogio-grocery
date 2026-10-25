import 'dart:async';

import 'package:flutter/foundation.dart';

import '../application/watch_grocery_list.dart';
import '../domain/grocery_list.dart';
import '../domain/week.dart';

class GroceryListViewModel extends ChangeNotifier {
  GroceryListViewModel(WatchGroceryList watchGroceryList, this.week) {
    _subscription = watchGroceryList(week).listen((list) {
      _list = list;
      _loading = false;
      notifyListeners();
    });
  }

  final Week week;
  late final StreamSubscription<GroceryList?> _subscription;

  GroceryList? _list;
  GroceryList? get list => _list;

  bool _loading = true;
  bool get loading => _loading;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
