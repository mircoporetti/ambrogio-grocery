import '../domain/access_token_port.dart';
import '../domain/account_exceptions.dart';
import '../domain/clock_port.dart';
import '../domain/refresh_token.dart';
import '../domain/session_storage_port.dart';
import 'session_tokens.dart';

class RefreshSession {
  RefreshSession(this._sessions, this._accessTokens, this._clock);

  final SessionStoragePort _sessions;
  final AccessTokenPort _accessTokens;
  final ClockPort _clock;

  Future<SessionTokens> call(String value) async {
    final now = _clock.now();
    final token = await _sessions.findRefreshToken(value);
    if (token == null) throw const InvalidRefreshTokenException();
    if (token.used) await _endStolenSession(token);
    if (!token.isActiveAt(now)) throw const InvalidRefreshTokenException();
    if (!await _sessions.markUsed(token)) await _endStolenSession(token);

    final next = RefreshToken.issue(token.session, now);
    await _sessions.saveRefreshToken(next);
    return SessionTokens(
      access: _accessTokens.issue(token.session.accountId, now),
      refresh: next,
    );
  }

  Future<Never> _endStolenSession(RefreshToken token) async {
    await _sessions.delete(token.session.id);
    throw const InvalidRefreshTokenException();
  }
}
