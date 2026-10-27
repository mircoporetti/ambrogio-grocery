import 'recipe_change.dart';

abstract interface class RecipeSyncStoragePort {
  Future<List<RecipeChange>> pendingChanges();

  Stream<int> watchPendingCount();

  Future<void> markPushed(List<RecipeChange> changes);

  Future<void> applyPulled(RecipeChangesPage page);

  Future<String?> cursor();

  Future<void> clear();
}
