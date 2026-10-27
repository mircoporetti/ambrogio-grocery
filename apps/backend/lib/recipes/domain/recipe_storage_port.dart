import '../../accounts/domain/account_id.dart';
import 'recipe_change.dart';

abstract interface class RecipeStoragePort {

  Future<void> apply(AccountId account, List<RecipeChange> changes);

  Future<RecipeChangesPage> changesAfter(
    AccountId account,
    int cursor, {
    required int limit,
  });
}
