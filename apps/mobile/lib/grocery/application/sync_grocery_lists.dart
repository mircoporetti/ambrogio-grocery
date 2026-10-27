import 'dart:developer';

import '../../account/application/call_with_session.dart';
import '../../account/domain/account_exceptions.dart';
import '../domain/grocery_list_change.dart';
import '../domain/grocery_list_sync_api_port.dart';
import '../domain/grocery_list_sync_exceptions.dart';
import '../domain/grocery_list_sync_storage_port.dart';

class SyncGroceryLists {
  SyncGroceryLists(this._storage, this._api, this._callWithSession);

  static const _pushBatch = 1000;

  final GroceryListSyncStoragePort _storage;
  final GroceryListSyncApiPort _api;
  final CallWithSession _callWithSession;

  Future<void> call() async {
    try {
      await _callWithSession((accessToken) async {
        await _push(accessToken);
        await _pull(accessToken);
      });
    } on GroceryListSyncException catch (e, stackTrace) {
      log('Syncing grocery lists failed', error: e, stackTrace: stackTrace);
    } on AccountException catch (e, stackTrace) {
      log('Syncing grocery lists failed', error: e, stackTrace: stackTrace);
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
    GroceryListChangesPage page;
    do {
      page = await _api.pull(accessToken, since: await _storage.cursor());
      await _storage.applyPulled(page);
    } while (page.hasMore);
  }
}
