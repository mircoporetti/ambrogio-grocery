@TestOn('browser')
library;

import 'package:ambrogio_grocery/account/data/web_lock_account_api_adapter.dart';
import 'package:ambrogio_grocery/account/domain/account_api_port.dart';
import 'package:ambrogio_grocery/account/domain/account_exceptions.dart';
import 'package:ambrogio_grocery/account/domain/auth_tokens.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('renewals from several tabs run one at a time', () async {
    final server = _SlowServer();
    final tabs = [
      WebLockAccountApiAdapter(server),
      WebLockAccountApiAdapter(server),
    ];

    final renewed = await Future.wait([
      for (final tab in tabs) tab.refresh(''),
    ]);

    expect(server.mostAtOnce, 1);
    expect([for (final t in renewed) t.access], ['access-1', 'access-2']);
  });

  test('a refused renewal still fails and frees the lock', () async {
    final server = _SlowServer()..refuseNext = true;
    final tab = WebLockAccountApiAdapter(server);

    await expectLater(
      tab.refresh(''),
      throwsA(isA<InvalidRefreshTokenException>()),
    );
    expect((await tab.refresh('')).access, 'access-1');
  });
}

class _SlowServer implements AccountApiPort {
  var _running = 0;
  var mostAtOnce = 0;
  var _issued = 0;
  var refuseNext = false;

  @override
  Future<AuthTokens> refresh(String refreshToken) async {
    _running++;
    if (_running > mostAtOnce) mostAtOnce = _running;
    await Future<void>.delayed(const Duration(milliseconds: 50));
    _running--;
    if (refuseNext) {
      refuseNext = false;
      throw const InvalidRefreshTokenException();
    }
    _issued++;
    return AuthTokens(access: 'access-$_issued', refresh: '');
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
