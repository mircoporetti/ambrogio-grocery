import 'dart:async';

import 'package:shared_preferences/shared_preferences.dart';

import '../domain/auth_tokens.dart';
import '../domain/session.dart';
import '../domain/session_storage_port.dart';

class BrowserSessionAdapter implements SessionStoragePort {
  BrowserSessionAdapter(this._preferences);

  static const _email = 'account.email';

  final SharedPreferencesAsync _preferences;
  final _changes = StreamController<Session?>.broadcast();
  String _accessToken = '';

  @override
  Future<Session?> load() async {
    final email = await _preferences.getString(_email);
    if (email == null) return null;
    return Session(
      email: email,
      tokens: AuthTokens(access: _accessToken, refresh: ''),
    );
  }

  @override
  Future<void> save(Session session) async {
    await _preferences.setString(_email, session.email);
    _accessToken = session.tokens.access;
    _changes.add(session);
  }

  @override
  Future<void> clear() async {
    await _preferences.remove(_email);
    _accessToken = '';
    _changes.add(null);
  }

  @override
  Stream<Session?> watch() async* {
    yield await load();
    yield* _changes.stream;
  }
}
