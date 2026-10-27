import '../../grocery/application/forget_local_grocery_lists.dart';
import '../../recipes/application/forget_local_recipes.dart';
import 'sync_lock.dart';

class ForgetLocalData {
  ForgetLocalData(this._recipes, this._groceryLists, this._lock);

  final ForgetLocalRecipes _recipes;
  final ForgetLocalGroceryLists _groceryLists;
  final SyncLock _lock;

  Future<void> call() => _lock.run(() async {
    await _recipes();
    await _groceryLists();
  });
}
