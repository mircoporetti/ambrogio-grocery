import '../../accounts/domain/account_id.dart';
import '../../photos/domain/photo_id.dart';
import 'recipe_change.dart';

abstract interface class RecipeStoragePort {
  Future<Set<PhotoId>> apply(AccountId account, List<RecipeChange> changes);
  Future<Set<PhotoId>> photosInUse(AccountId account, Set<PhotoId> photos);

  Future<RecipeChangesPage> changesAfter(
    AccountId account,
    int cursor, {
    required int limit,
  });
}
