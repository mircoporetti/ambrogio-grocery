import 'refresh_token.dart';
import 'session.dart';
import 'session_id.dart';

abstract interface class SessionStoragePort {
  Future<void> save(Session session);

  Future<void> saveRefreshToken(RefreshToken token);

  Future<RefreshToken?> findRefreshToken(String value);

  /// Marks [token] as used, unless it already was. Returns false if it was,
  /// so two requests with the same token can't both succeed.
  Future<bool> markUsed(RefreshToken token);

  Future<void> delete(SessionId id);
}
