import '../../accounts/domain/account_id.dart';
import '../domain/recipe_change.dart';
import '../domain/recipe_storage_port.dart';

class PullRecipeChanges {
  PullRecipeChanges(this._recipes);

  static const defaultLimit = 500;
  static const maxLimit = 1000;

  final RecipeStoragePort _recipes;

  Future<RecipeChangesPage> call(
    AccountId account, {
    int after = 0,
    int limit = defaultLimit,
  }) => _recipes.changesAfter(account, after, limit: limit);
}
