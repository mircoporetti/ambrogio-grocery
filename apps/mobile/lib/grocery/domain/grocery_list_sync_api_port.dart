import 'grocery_list_change.dart';

abstract interface class GroceryListSyncApiPort {
  Future<void> push(String accessToken, List<GroceryListChange> changes);

  Future<GroceryListChangesPage> pull(String accessToken, {String? since});
}
