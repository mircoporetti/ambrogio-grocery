import 'dart:async';
import 'dart:developer';

import 'package:flutter/foundation.dart';

import '../application/delete_grocery_list.dart';
import '../application/tick_grocery_item.dart';
import '../application/watch_grocery_list.dart';
import '../domain/grocery_item.dart';
import '../domain/grocery_item_id.dart';
import '../domain/grocery_list.dart';
import '../domain/week.dart';
import 'grocery_error.dart';

class GroceryListViewModel extends ChangeNotifier {
  GroceryListViewModel(
    WatchGroceryList watchGroceryList,
    this._tickGroceryItem,
    this._deleteGroceryList,
    this.week,
  ) {
    _subscription = watchGroceryList(week).listen((list) {
      _list = list;
      _loading = false;
      notifyListeners();
    });
  }

  final TickGroceryItem _tickGroceryItem;
  final DeleteGroceryList _deleteGroceryList;
  final Week week;
  late final StreamSubscription<GroceryList?> _subscription;

  GroceryList? _list;
  GroceryList? get list => _list;

  bool _loading = true;
  bool get loading => _loading;

  GroceryError? _error;
  GroceryError? get error => _error;

  bool _deleting = false;
  bool get deleting => _deleting;

  List<GroceryItem> get items => [...?_list?.items];

  Future<void> toggle(GroceryItemId id) async {
    final list = _list;
    final item = list?.items.where((i) => i.id == id).firstOrNull;
    if (list == null || item == null) return;
    final ticked = !item.ticked;
    _error = null;
    notifyListeners();
    try {
      await _tickGroceryItem(list.id, id, ticked: ticked);
    } on Exception catch (e, stackTrace) {
      log('Ticking grocery item failed', error: e, stackTrace: stackTrace);
      _error = const UpdateFailed();
      notifyListeners();
    }
  }

  Future<bool> delete() async {
    final list = _list;
    if (list == null) return false;
    _deleting = true;
    _error = null;
    notifyListeners();
    try {
      await _deleteGroceryList(list.id);
      return true;
    } on Exception catch (e, stackTrace) {
      log('Deleting grocery list failed', error: e, stackTrace: stackTrace);
      _error = const DeleteFailed();
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
