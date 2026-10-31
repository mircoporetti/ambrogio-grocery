import 'package:test/test.dart';

import 'support/accounts_api.dart';
import 'support/api_client.dart';
import 'support/web_sessions_api.dart';

void main() {
  late ApiClient api;
  late AccountsApi accounts;
  late WebSessionsApi web;

  setUp(() async {
    api = await ApiClient.start();
    accounts = AccountsApi(api);
    web = WebSessionsApi(api);
    await accounts.register('ada@example.com', 'secret-pw');
  });

  group('the web app', () {
    test('may call the API from its origin', () async {
      final preflight = await web.preflight('/recipes/changes', 'POST');

      expect(preflight.status, 204);
      expect(
        preflight.header('access-control-allow-origin'),
        WebSessionsApi.webOrigin,
      );
      expect(preflight.header('access-control-allow-credentials'), 'true');
      expect(
        preflight.header('access-control-allow-headers'),
        contains('authorization'),
      );

      final response = await web.logIn('ada@example.com', 'secret-pw');
      expect(
        response.header('access-control-allow-origin'),
        WebSessionsApi.webOrigin,
      );
    });

    test('other sites may not call it', () async {
      final other = WebSessionsApi(api, origin: 'https://evil.test');

      final preflight = await other.preflight('/sessions', 'POST');

      expect(preflight.status, 403);
      expect(preflight.header('access-control-allow-origin'), isNull);
    });

    test('gets the refresh token only in an httpOnly cookie for the session '
        'endpoints', () async {
      final response = await web.logIn('ada@example.com', 'secret-pw');

      expect(response.status, 200);
      expect(response['accessToken'], isA<String>());
      expect(response.json, isNot(contains('refreshToken')));
      final cookie = response.header('set-cookie')!.toLowerCase();
      for (final attribute in [
        'httponly',
        'secure',
        'samesite=strict',
        'path=/sessions',
        'max-age=${30 * 24 * 60 * 60}',
      ]) {
        expect(cookie, contains(attribute));
      }
    });

    test('refreshes with the cookie, which changes each time', () async {
      await web.logIn('ada@example.com', 'secret-pw');
      final first = web.cookie;

      final response = await web.refresh();

      expect(response.status, 200);
      expect(
        (await accounts.me(response['accessToken'] as String)).status,
        200,
      );
      expect(web.cookie, isNot(first));
    });

    test('without the cookie it has no session', () async {
      final response = await web.refresh();

      expect(response.status, 401);
      expect(response['error'], 'invalid_refresh_token');
    });

    test('a cookie sent from another site is ignored', () async {
      await web.logIn('ada@example.com', 'secret-pw');
      final other = WebSessionsApi(api, origin: 'https://evil.test')
        ..cookie = web.cookie;

      final response = await other.refresh();

      expect(response.status, isNot(200));
      expect((await web.refresh()).status, 200);
    });

    test('logging out ends the session and removes the cookie', () async {
      await web.logIn('ada@example.com', 'secret-pw');
      final cookie = web.cookie;

      final response = await web.logOut();

      expect(response.status, 204);
      expect(
        response.header('set-cookie')!.toLowerCase(),
        contains('max-age=0'),
      );
      web.cookie = cookie;
      expect((await web.refresh()).status, 401);
    });
  });

  test('the phone app still gets the refresh token in the body', () async {
    final response = await accounts.logIn('ada@example.com', 'secret-pw');

    expect(response['refreshToken'], isA<String>());
    expect(response.header('set-cookie'), isNull);
  });
}
