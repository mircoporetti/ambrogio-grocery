import '../domain/account_api_port.dart';
import '../domain/session.dart';
import '../domain/session_storage_port.dart';

class LogIn {
  LogIn(this._api, this._sessions);

  final AccountApiPort _api;
  final SessionStoragePort _sessions;

  Future<void> call({required String email, required String password}) async {
    final tokens = await _api.logIn(email: email, password: password);
    final accountEmail = await _api.currentEmail(tokens.access);
    await _sessions.save(Session(email: accountEmail, tokens: tokens));
  }
}
