import '../domain/session_storage_port.dart';

class LogOut {
  LogOut(this._sessions);

  final SessionStoragePort _sessions;

  Future<void> call(String refreshToken) async {
    final token = await _sessions.findRefreshToken(refreshToken);
    if (token != null) await _sessions.delete(token.session.id);
  }
}
