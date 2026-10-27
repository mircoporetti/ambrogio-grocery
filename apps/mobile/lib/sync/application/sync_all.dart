import '../../grocery/application/sync_grocery_lists.dart';
import '../../recipes/application/sync_recipes.dart';
import 'sync_lock.dart';

class SyncAll {
  SyncAll(this._recipes, this._groceryLists, this._lock);

  final SyncRecipes _recipes;
  final SyncGroceryLists _groceryLists;
  final SyncLock _lock;

  Future<void>? _queued;

  /// Requests made while a sync waits to start share it.
  Future<void> call() => _queued ??= _lock.run(() async {
    _queued = null;
    await _recipes();
    await _groceryLists();
  });
}
