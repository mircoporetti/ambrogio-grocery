import 'dart:async';
import 'dart:developer';

import 'package:flutter/foundation.dart';

import '../application/tick_grocery_item.dart';
import '../application/watch_grocery_list.dart';
import '../domain/grocery_item.dart';
import '../domain/grocery_list.dart';
import '../domain/week.dart';

class GroceryListViewModel extends ChangeNotifier {
  GroceryListViewModel(
    WatchGroceryList watchGroceryList,
    this._tickGroceryItem,
    this.week,
  ) {
    _subscription = watchGroceryList(week).listen((list) {
      _list = list;
      _loading = false;
      notifyListeners();
    });
  }

  final TickGroceryItem _tickGroceryItem;
  final Week week;
  late final StreamSubscription<GroceryList?> _subscription;

  GroceryList? _list;
  GroceryList? get list => _list;

  bool _loading = true;
  bool get loading => _loading;

  String? _error;
  String? get error => _error;

  List<(int, GroceryItem)> get items => [...?_list?.items.indexed];

  Future<void> toggle(int index) async {
    final list = _list;
    if (list == null) return;
    final ticked = !list.items[index].ticked;
    _error = null;
    notifyListeners();
    try {
      await _tickGroceryItem(list.id, index, ticked: ticked);
    } on Exception catch (e, stackTrace) {
      log('Ticking grocery item failed', error: e, stackTrace: stackTrace);
      _error = 'Could not update the grocery list. Please try again.';
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
