import 'recipe_change.dart';

abstract interface class RecipeSyncApiPort {
  Future<void> push(String accessToken, List<RecipeChange> changes);

  Future<RecipeChangesPage> pull(String accessToken, {String? since});
}
