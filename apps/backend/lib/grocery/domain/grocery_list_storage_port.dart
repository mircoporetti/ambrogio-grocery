import '../../accounts/domain/account_id.dart';
import 'grocery_list_change.dart';

abstract interface class GroceryListStoragePort {
  Future<void> apply(AccountId account, List<GroceryListChange> changes);

  Future<GroceryListChangesPage> changesAfter(
    AccountId account,
    int cursor, {
    required int limit,
  });
}
