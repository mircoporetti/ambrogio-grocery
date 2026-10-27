import 'package:test/test.dart';

import 'support/accounts_api.dart';
import 'support/api_client.dart';

void main() {
  late AccountsApi accounts;

  Future<void> startServer() async =>
      accounts = AccountsApi(await ApiClient.start());

  group('registering', () {
    setUp(startServer);

    test('creates an account', () async {
      final response = await accounts.register('ada@example.com', 'secret-pw');

      expect(response.status, 201);
      expect(response['email'], 'ada@example.com');
      expect(response['id'], isA<String>());
    });

    test('stores the email trimmed and in lower case', () async {
      final response = await accounts.register(
        '  Ada@Example.COM ',
        'secret-pw',
      );

      expect(response['email'], 'ada@example.com');
    });

    test('an email can only be registered once, in any case', () async {
      await accounts.register('ada@example.com', 'secret-pw');

      final response = await accounts.register('ADA@example.com', 'other-pw');

      expect(response.status, 409);
      expect(response['error'], 'email_taken');
    });

    test('rejects an invalid email', () async {
      for (final email in ['', 'ada', 'ada@', '@example.com', 'a da@x.com']) {
        final response = await accounts.register(email, 'secret-pw');

        expect(response.status, 400, reason: email);
        expect(response['error'], 'invalid_email', reason: email);
      }
    });

    test('rejects a password shorter than 8 characters', () async {
      final response = await accounts.register('ada@example.com', 'short');

      expect(response.status, 400);
      expect(response['error'], 'password_too_short');
    });

    test('rejects a password longer than 72 bytes', () async {
      final response = await accounts.register('ada@example.com', 'é' * 37);

      expect(response.status, 400);
      expect(response['error'], 'password_too_long');
    });

    test('rejects a body that is not the expected JSON', () async {
      final api = await ApiClient.start();

      for (final body in ['not json', '[]', '{"email": 1}']) {
        final response = await api.postRaw('/accounts', body);

        expect(response.status, 400, reason: body);
        expect(response['error'], 'invalid_request', reason: body);
      }
    });
  });
}
