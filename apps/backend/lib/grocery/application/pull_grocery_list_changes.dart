import '../../accounts/domain/account_id.dart';
import '../domain/grocery_list_change.dart';
import '../domain/grocery_list_storage_port.dart';

class PullGroceryListChanges {
  PullGroceryListChanges(this._lists);

  static const defaultLimit = 500;
  static const maxLimit = 1000;

  final GroceryListStoragePort _lists;

  Future<GroceryListChangesPage> call(
    AccountId account, {
    int after = 0,
    int limit = defaultLimit,
  }) => _lists.changesAfter(account, after, limit: limit);
}
