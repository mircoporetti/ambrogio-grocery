import '../../accounts/domain/account_id.dart';
import '../domain/recipe_change.dart';
import '../domain/recipe_exceptions.dart';
import '../domain/recipe_storage_port.dart';

class PushRecipeChanges {
  PushRecipeChanges(this._recipes);

  static const maxChanges = 1000;

  final RecipeStoragePort _recipes;

  Future<void> call(AccountId account, List<RecipeChange> changes) async {
    if (changes.length > maxChanges) throw const TooManyChangesException();
    if (changes.isEmpty) return;
    await _recipes.apply(account, changes);
  }
}
