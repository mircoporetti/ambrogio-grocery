import '../../accounts/domain/account_id.dart';
import '../domain/grocery_exceptions.dart';
import '../domain/grocery_list_change.dart';
import '../domain/grocery_list_storage_port.dart';

class PushGroceryListChanges {
  PushGroceryListChanges(this._lists);

  static const maxChanges = 1000;

  final GroceryListStoragePort _lists;

  Future<void> call(AccountId account, List<GroceryListChange> changes) async {
    if (changes.length > maxChanges) {
      throw const TooManyGroceryListChangesException();
    }
    if (changes.isEmpty) return;
    await _lists.apply(account, changes);
  }
}
