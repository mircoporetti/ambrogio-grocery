import 'dart:developer';

import '../../account/application/call_with_session.dart';
import '../../account/domain/account_exceptions.dart';
import '../domain/recipe_change.dart';
import '../domain/recipe_sync_api_port.dart';
import '../domain/recipe_sync_exceptions.dart';
import '../domain/recipe_sync_storage_port.dart';

class SyncRecipes {
  SyncRecipes(this._storage, this._api, this._callWithSession);

  static const _pushBatch = 1000;

  final RecipeSyncStoragePort _storage;
  final RecipeSyncApiPort _api;
  final CallWithSession _callWithSession;
  Future<void> call() async {
    try {
      await _callWithSession((accessToken) async {
        await _push(accessToken);
        await _pull(accessToken);
      });
    } on RecipeSyncException catch (e, stackTrace) {
      log('Syncing recipes failed', error: e, stackTrace: stackTrace);
    } on AccountException catch (e, stackTrace) {
      log('Syncing recipes failed', error: e, stackTrace: stackTrace);
    }
  }

  Future<void> _push(String accessToken) async {
    final pending = await _storage.pendingChanges();
    for (var start = 0; start < pending.length; start += _pushBatch) {
      final batch = pending.sublist(
        start,
        (start + _pushBatch).clamp(0, pending.length),
      );
      await _api.push(accessToken, batch);
      await _storage.markPushed(batch);
    }
  }

  Future<void> _pull(String accessToken) async {
    RecipeChangesPage page;
    do {
      page = await _api.pull(accessToken, since: await _storage.cursor());
      await _storage.applyPulled(page);
    } while (page.hasMore);
  }
}
