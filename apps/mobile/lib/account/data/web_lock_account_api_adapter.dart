import 'dart:js_interop';

import 'package:web/web.dart' as web;

import '../domain/account_api_port.dart';
import '../domain/auth_tokens.dart';

class WebLockAccountApiAdapter implements AccountApiPort {
  WebLockAccountApiAdapter(this._api);

  final AccountApiPort _api;

  static const _lock = 'ambrogio.session.refresh';

  @override
  Future<AuthTokens> refresh(String refreshToken) async {
    late final Future<AuthTokens> renewal;
    await web.window.navigator.locks
        .request(
          _lock,
          ((web.Lock? _) {
            renewal = _api.refresh(refreshToken);
            return renewal.then((_) {}, onError: (_) {}).toJS;
          }).toJS,
        )
        .toDart;
    return renewal;
  }

  @override
  Future<void> register({required String email, required String password}) =>
      _api.register(email: email, password: password);

  @override
  Future<AuthTokens> logIn({required String email, required String password}) =>
      _api.logIn(email: email, password: password);

  @override
  Future<String> currentEmail(String accessToken) =>
      _api.currentEmail(accessToken);

  @override
  Future<void> logOut(String refreshToken) => _api.logOut(refreshToken);
}
