import 'dart:convert';
import 'dart:io';

import 'package:ambrogio_grocery/account/data/http_account_api_adapter.dart';
import 'package:ambrogio_grocery/account/domain/account_exceptions.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  final baseUrl = Uri.parse('http://api.test:8080');

  http.Response json(int status, Object body) => http.Response(
    jsonEncode(body),
    status,
    headers: {'content-type': 'application/json'},
  );

  test('logs in with the email and password and returns the tokens', () async {
    late http.Request sent;
    final api = HttpAccountApiAdapter(
      baseUrl,
      MockClient((request) async {
        sent = request;
        return json(200, {
          'tokenType': 'Bearer',
          'accessToken': 'the-access',
          'expiresIn': 900,
          'refreshToken': 'the-refresh',
        });
      }),
    );

    final tokens = await api.logIn(email: 'ada@example.com', password: 'pw');

    expect(sent.method, 'POST');
    expect(sent.url.toString(), 'http://api.test:8080/sessions');
    expect(sent.headers['content-type'], startsWith('application/json'));
    expect(jsonDecode(sent.body), {
      'email': 'ada@example.com',
      'password': 'pw',
    });
    expect((tokens.access, tokens.refresh), ('the-access', 'the-refresh'));
  });

  test('registers, reads the account and logs out', () async {
    final sent = <http.Request>[];
    final api = HttpAccountApiAdapter(
      baseUrl,
      MockClient((request) async {
        sent.add(request);
        return switch (request.url.path) {
          '/accounts' => json(201, {'id': 'x', 'email': 'ada@example.com'}),
          '/me' => json(200, {'id': 'x', 'email': 'ada@example.com'}),
          _ => http.Response('', 204),
        };
      }),
    );

    await api.register(email: 'ada@example.com', password: 'secret-pw');
    final email = await api.currentEmail('the-access');
    await api.logOut('the-refresh');

    expect(email, 'ada@example.com');
    expect(
      [for (final r in sent) '${r.method} ${r.url.path}'],
      ['POST /accounts', 'GET /me', 'POST /sessions/logout'],
    );
    expect(sent[1].headers['authorization'], 'Bearer the-access');
    expect(jsonDecode(sent[2].body), {'refreshToken': 'the-refresh'});
  });

  test('renews the tokens with the refresh token', () async {
    late http.Request sent;
    final api = HttpAccountApiAdapter(
      baseUrl,
      MockClient((request) async {
        sent = request;
        return json(200, {
          'tokenType': 'Bearer',
          'accessToken': 'new-access',
          'expiresIn': 900,
          'refreshToken': 'new-refresh',
        });
      }),
    );

    final tokens = await api.refresh('old-refresh');

    expect(sent.method, 'POST');
    expect(sent.url.toString(), 'http://api.test:8080/sessions/refresh');
    expect(jsonDecode(sent.body), {'refreshToken': 'old-refresh'});
    expect((tokens.access, tokens.refresh), ('new-access', 'new-refresh'));
  });

  test('turns the backend error codes into exceptions', () async {
    final expected = {
      (400, 'invalid_email'): isA<InvalidEmailException>(),
      (400, 'password_too_short'): isA<PasswordTooShortException>(),
      (400, 'password_too_long'): isA<PasswordTooLongException>(),
      (409, 'email_taken'): isA<EmailTakenException>(),
      (401, 'invalid_credentials'): isA<InvalidCredentialsException>(),
      (401, 'invalid_refresh_token'): isA<InvalidRefreshTokenException>(),
      (401, 'unauthorized'): isA<AccessTokenRejectedException>(),
      (400, 'invalid_request'): isA<UnexpectedResponseException>(),
      (500, 'anything'): isA<UnexpectedResponseException>(),
    };
    for (final MapEntry(key: (status, code), value: matcher)
        in expected.entries) {
      final api = HttpAccountApiAdapter(
        baseUrl,
        MockClient((_) async => json(status, {'error': code})),
      );

      await expectLater(
        api.register(email: 'ada@example.com', password: 'secret-pw'),
        throwsA(matcher),
        reason: code,
      );
    }
  });

  test('a response that is not the expected JSON is unexpected', () async {
    for (final response in [
      http.Response('<html>proxy error</html>', 502),
      http.Response('not json', 200),
      json(200, {'accessToken': 1}),
    ]) {
      final api = HttpAccountApiAdapter(
        baseUrl,
        MockClient((_) async => response),
      );

      await expectLater(
        api.logIn(email: 'ada@example.com', password: 'pw'),
        throwsA(isA<UnexpectedResponseException>()),
        reason: response.body,
      );
    }
  });

  test('a network failure means the server is unreachable', () async {
    final api = HttpAccountApiAdapter(
      baseUrl,
      MockClient((request) async {
        throw http.ClientException(
          const SocketException('Connection refused').toString(),
          request.url,
        );
      }),
    );

    await expectLater(
      api.logIn(email: 'ada@example.com', password: 'pw'),
      throwsA(isA<ServerUnreachableException>()),
    );
  });
}
