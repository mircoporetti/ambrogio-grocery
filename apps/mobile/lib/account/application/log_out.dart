import 'dart:developer';

import '../domain/account_api_port.dart';
import '../domain/account_exceptions.dart';
import '../domain/session_storage_port.dart';

class LogOut {
  LogOut(this._api, this._sessions, this._forgetLocalData);

  final AccountApiPort _api;
  final SessionStoragePort _sessions;

  /// Removes the account's data from the phone; it stays on the server.
  final Future<void> Function() _forgetLocalData;

  Future<void> call() async {
    final session = await _sessions.load();
    if (session == null) return;
    await _sessions.clear();
    await _forgetLocalData();
    // Offline, the server session stays until its refresh token expires.
    try {
      await _api.logOut(session.tokens.refresh);
    } on AccountException catch (e, stackTrace) {
      log('Ending the server session failed', error: e, stackTrace: stackTrace);
    }
  }
}
