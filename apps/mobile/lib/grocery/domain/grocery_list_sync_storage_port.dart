import 'grocery_list_change.dart';

abstract interface class GroceryListSyncStoragePort {
  Future<List<GroceryListChange>> pendingChanges();

  Stream<int> watchPendingCount();

  Future<void> markPushed(List<GroceryListChange> changes);

  Future<void> applyPulled(GroceryListChangesPage page);

  Future<String?> cursor();

  Future<void> clear();
}
