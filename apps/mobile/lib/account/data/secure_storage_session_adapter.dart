import 'dart:async';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../domain/auth_tokens.dart';
import '../domain/session.dart';
import '../domain/session_storage_port.dart';

class SecureStorageSessionAdapter implements SessionStoragePort {
  SecureStorageSessionAdapter(this._storage);

  static const _email = 'account.email';
  static const _accessToken = 'account.accessToken';
  static const _refreshToken = 'account.refreshToken';

  final FlutterSecureStorage _storage;
  final _changes = StreamController<Session?>.broadcast();

  @override
  Future<Session?> load() async {
    final email = await _storage.read(key: _email);
    final access = await _storage.read(key: _accessToken);
    final refresh = await _storage.read(key: _refreshToken);
    if (email == null || access == null || refresh == null) return null;
    return Session(
      email: email,
      tokens: AuthTokens(access: access, refresh: refresh),
    );
  }

  @override
  Future<void> save(Session session) async {
    await _storage.write(key: _email, value: session.email);
    await _storage.write(key: _accessToken, value: session.tokens.access);
    await _storage.write(key: _refreshToken, value: session.tokens.refresh);
    _changes.add(session);
  }

  @override
  Future<void> clear() async {
    for (final key in [_email, _accessToken, _refreshToken]) {
      await _storage.delete(key: key);
    }
    _changes.add(null);
  }

  @override
  Stream<Session?> watch() async* {
    yield await load();
    yield* _changes.stream;
  }
}
