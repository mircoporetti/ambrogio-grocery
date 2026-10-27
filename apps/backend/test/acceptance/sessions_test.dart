import 'package:test/test.dart';

import 'support/accounts_api.dart';
import 'support/api_client.dart';
import 'support/fixed_clock_adapter.dart';
import 'support/forged_tokens.dart';
import 'support/test_database.dart';

void main() {
  late FixedClockAdapter clock;
  late AccountsApi accounts;

  setUp(() async {
    clock = FixedClockAdapter();
    accounts = AccountsApi(await ApiClient.start(clock: clock));
  });

  group('logging in', () {
    test(
      'with the right password gives an access and a refresh token',
      () async {
        await accounts.register('ada@example.com', 'secret-pw');

        final response = await accounts.logIn('ada@example.com', 'secret-pw');

        expect(response.status, 200);
        expect(response['tokenType'], 'Bearer');
        expect(response['accessToken'], isA<String>());
        expect(response['expiresIn'], 15 * 60);
        expect(response['refreshToken'], isA<String>());
      },
    );

    test('the email is matched in any case', () async {
      await accounts.register('ada@example.com', 'secret-pw');

      final response = await accounts.logIn(' ADA@example.com', 'secret-pw');

      expect(response.status, 200);
    });

    test('a wrong password and an unknown email look the same', () async {
      await accounts.register('ada@example.com', 'secret-pw');

      final wrongPassword = await accounts.logIn(
        'ada@example.com',
        'nope-nope',
      );
      final unknownEmail = await accounts.logIn('bob@example.com', 'secret-pw');

      for (final response in [wrongPassword, unknownEmail]) {
        expect(response.status, 401);
        expect(response['error'], 'invalid_credentials');
      }
    });

    test('each login gives different tokens', () async {
      await accounts.register('ada@example.com', 'secret-pw');

      final first = await accounts.logInTokens('ada@example.com', 'secret-pw');
      clock.advance(const Duration(seconds: 1));
      final second = await accounts.logInTokens('ada@example.com', 'secret-pw');

      expect(first.access, isNot(second.access));
      expect(first.refresh, isNot(second.refresh));
    });
  });

  group('the access token', () {
    test('shows its own account', () async {
      final registered = await accounts.register('ada@example.com', 'pw-ada-1');
      final ada = await accounts.logInTokens('ada@example.com', 'pw-ada-1');
      final bob = await accounts.registerAndLogIn(
        'bob@example.com',
        'pw-bob-1',
      );

      final response = await accounts.me(ada.access);

      expect(response.status, 200);
      expect(response.json, {
        'id': registered['id'],
        'email': 'ada@example.com',
      });
      expect((await accounts.me(bob.access))['email'], 'bob@example.com');
    });

    test('is needed and must be valid', () async {
      for (final token in [null, '', 'made-up-token', 'a.b.c']) {
        final response = await accounts.me(token);

        expect(response.status, 401, reason: '$token');
        expect(response['error'], 'unauthorized', reason: '$token');
        expect(response.header('www-authenticate'), 'Bearer');
      }
    });

    test('expires 15 minutes after it was issued', () async {
      final tokens = await accounts.registerAndLogIn(
        'ada@example.com',
        'pw-ada-1',
      );

      clock.advance(const Duration(minutes: 15) - const Duration(seconds: 1));
      expect((await accounts.me(tokens.access)).status, 200);

      clock.advance(const Duration(seconds: 1));
      expect((await accounts.me(tokens.access)).status, 401);
    });

    test('is rejected if its claims were changed', () async {
      final ada = await accounts.registerAndLogIn(
        'ada@example.com',
        'pw-ada-1',
      );
      final bob = await accounts.register('bob@example.com', 'pw-bob-1');
      final later = clock.now().add(const Duration(days: 365));

      final forged = [
        withClaims(ada.access, {'sub': bob['id']}),
        withClaims(ada.access, {'exp': later.millisecondsSinceEpoch ~/ 1000}),
        unsigned(ada.access),
      ];

      for (final token in forged) {
        expect((await accounts.me(token)).status, 401, reason: token);
      }
    });

    test('is rejected by a server with another signing secret', () async {
      final tokens = await accounts.registerAndLogIn(
        'ada@example.com',
        'pw-ada-1',
      );
      final other = AccountsApi(
        await ApiClient.start(
          jwtSecret: 'another-secret-of-at-least-32-bytes!',
        ),
      );

      expect((await other.me(tokens.access)).status, 401);
    });
  });

  group('refreshing', () {
    test('gives a new access and refresh token', () async {
      final first = await accounts.registerAndLogIn(
        'ada@example.com',
        'pw-ada-1',
      );
      clock.advance(const Duration(minutes: 20));
      expect((await accounts.me(first.access)).status, 401);

      final response = await accounts.refresh(first.refresh);

      expect(response.status, 200);
      expect(response['tokenType'], 'Bearer');
      expect(response['expiresIn'], 15 * 60);
      final next = (
        access: response['accessToken']! as String,
        refresh: response['refreshToken']! as String,
      );
      expect(next.refresh, isNot(first.refresh));
      expect((await accounts.me(next.access))['email'], 'ada@example.com');
    });

    test('a refresh token can be used only once', () async {
      final first = await accounts.registerAndLogIn(
        'ada@example.com',
        'pw-ada-1',
      );
      await accounts.refreshTokens(first.refresh);

      final again = await accounts.refresh(first.refresh);

      expect(again.status, 401);
      expect(again['error'], 'invalid_refresh_token');
    });

    test('reusing an old refresh token ends the whole session', () async {
      final first = await accounts.registerAndLogIn(
        'ada@example.com',
        'pw-ada-1',
      );
      final second = await accounts.refreshTokens(first.refresh);

      await accounts.refresh(first.refresh);

      expect((await accounts.refresh(second.refresh)).status, 401);
    });

    test('reusing a refresh token leaves other sessions alone', () async {
      await accounts.register('ada@example.com', 'pw-ada-1');
      final phone = await accounts.logInTokens('ada@example.com', 'pw-ada-1');
      final tablet = await accounts.logInTokens('ada@example.com', 'pw-ada-1');
      await accounts.refreshTokens(phone.refresh);

      await accounts.refresh(phone.refresh);

      expect((await accounts.refresh(tablet.refresh)).status, 200);
    });

    test('a refresh token expires 30 days after it was issued', () async {
      final first = await accounts.registerAndLogIn(
        'ada@example.com',
        'pw-ada-1',
      );
      final copy = first.refresh;

      clock.advance(const Duration(days: 30));

      expect((await accounts.refresh(copy)).status, 401);
    });

    test('each refresh keeps the session going for 30 more days', () async {
      var tokens = await accounts.registerAndLogIn(
        'ada@example.com',
        'pw-ada-1',
      );

      for (var i = 0; i < 3; i++) {
        clock.advance(const Duration(days: 29));
        tokens = await accounts.refreshTokens(tokens.refresh);
      }

      expect((await accounts.me(tokens.access)).status, 200);
    });

    test('rejects an unknown refresh token', () async {
      for (final token in ['', 'made-up-token']) {
        final response = await accounts.refresh(token);

        expect(response.status, 401, reason: token);
        expect(response['error'], 'invalid_refresh_token', reason: token);
      }
    });
  });

  group('logging out', () {
    test('ends the session', () async {
      final tokens = await accounts.registerAndLogIn(
        'ada@example.com',
        'pw-ada-1',
      );

      final response = await accounts.logOut(tokens.refresh);

      expect(response.status, 204);
      expect((await accounts.refresh(tokens.refresh)).status, 401);
    });

    test('keeps the other sessions of the same account', () async {
      await accounts.register('ada@example.com', 'pw-ada-1');
      final phone = await accounts.logInTokens('ada@example.com', 'pw-ada-1');
      final tablet = await accounts.logInTokens('ada@example.com', 'pw-ada-1');

      await accounts.logOut(phone.refresh);

      expect((await accounts.refresh(tablet.refresh)).status, 200);
    });

    test('with an unknown refresh token still succeeds', () async {
      expect((await accounts.logOut('made-up-token')).status, 204);
    });
  });

  test('sessions survive a server restart', () async {
    final endpoint = await newTestDatabase();
    final firstRun = await ApiClient.start(
      database: openDatabaseAt(endpoint),
      clock: clock,
    );
    final tokens = await AccountsApi(
      firstRun,
    ).registerAndLogIn('ada@example.com', 'secret-pw');
    await firstRun.stop();

    accounts = AccountsApi(
      await ApiClient.start(database: openDatabaseAt(endpoint), clock: clock),
    );

    expect((await accounts.me(tokens.access))['email'], 'ada@example.com');
    expect((await accounts.refresh(tokens.refresh)).status, 200);
  });
}
