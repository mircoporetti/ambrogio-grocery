import '../domain/account_api_port.dart';
import '../domain/account_exceptions.dart';
import '../domain/session.dart';
import '../domain/session_storage_port.dart';

class CallWithSession {
  CallWithSession(this._api, this._sessions);

  final AccountApiPort _api;
  final SessionStoragePort _sessions;

  // The server ends a session whose refresh token is used twice, so
  // concurrent calls share one renewal.
  Future<Session?>? _renewing;

  Future<T?> call<T>(Future<T> Function(String accessToken) request) async {
    final session = await _sessions.load();
    if (session == null) return null;
    try {
      return await request(session.tokens.access);
    } on AccessTokenRejectedException {
      final renewed = await (_renewing ??= _renew(
        session,
      ).whenComplete(() => _renewing = null));
      if (renewed == null) return null;
      return request(renewed.tokens.access);
    }
  }

  Future<Session?> _renew(Session rejected) async {
    final current = await _sessions.load();
    if (current == null) return null;
    if (current.tokens.access != rejected.tokens.access) return current;
    try {
      final tokens = await _api.refresh(current.tokens.refresh);
      if ((await _sessions.load())?.tokens.refresh != current.tokens.refresh) {
        return null;
      }
      final renewed = Session(email: current.email, tokens: tokens);
      await _sessions.save(renewed);
      return renewed;
    } on InvalidRefreshTokenException {
      await _sessions.clear();
      return null;
    }
  }
}
