import 'recipe.dart';
import 'recipe_id.dart';

class RecipeChange {
  RecipeChange({required this.id, required DateTime updatedAt, this.recipe})
    : updatedAt = updatedAt.toUtc();

  final RecipeId id;
  final DateTime updatedAt;
  final Recipe? recipe;

  bool get deleted => recipe == null;

  bool supersedes(DateTime? current) =>
      current == null || updatedAt.isAfter(current);
}

class RecipeChangesPage {
  RecipeChangesPage({
    required this.changes,
    required this.cursor,
    required this.hasMore,
  });

  final List<RecipeChange> changes;

  final int cursor;
  final bool hasMore;
}
