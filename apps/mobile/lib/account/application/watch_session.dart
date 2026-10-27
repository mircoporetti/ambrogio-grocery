import '../domain/session.dart';
import '../domain/session_storage_port.dart';

class WatchSession {
  WatchSession(this._sessions);

  final SessionStoragePort _sessions;

  Stream<Session?> call() => _sessions.watch();
}
