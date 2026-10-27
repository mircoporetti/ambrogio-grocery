import 'session.dart';

abstract interface class SessionStoragePort {
  Future<Session?> load();

  Future<void> save(Session session);

  Future<void> clear();

  Stream<Session?> watch();
}
