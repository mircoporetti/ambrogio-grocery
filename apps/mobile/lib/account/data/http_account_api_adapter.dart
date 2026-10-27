import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../domain/account_api_port.dart';
import '../domain/account_exceptions.dart';
import '../domain/auth_tokens.dart';

class HttpAccountApiAdapter implements AccountApiPort {
  HttpAccountApiAdapter(this._baseUrl, this._client);

  final Uri _baseUrl;
  final http.Client _client;

  static const _timeout = Duration(seconds: 15);

  @override
  Future<void> register({required String email, required String password}) =>
      _send('POST', '/accounts', body: {'email': email, 'password': password});

  @override
  Future<AuthTokens> logIn({
    required String email,
    required String password,
  }) async {
    final json = await _send(
      'POST',
      '/sessions',
      body: {'email': email, 'password': password},
    );
    return AuthTokens(
      access: _string(json, 'accessToken'),
      refresh: _string(json, 'refreshToken'),
    );
  }

  @override
  Future<AuthTokens> refresh(String refreshToken) async {
    final json = await _send(
      'POST',
      '/sessions/refresh',
      body: {'refreshToken': refreshToken},
    );
    return AuthTokens(
      access: _string(json, 'accessToken'),
      refresh: _string(json, 'refreshToken'),
    );
  }

  @override
  Future<String> currentEmail(String accessToken) async =>
      _string(await _send('GET', '/me', token: accessToken), 'email');

  @override
  Future<void> logOut(String refreshToken) =>
      _send('POST', '/sessions/logout', body: {'refreshToken': refreshToken});

  Future<Map<String, Object?>?> _send(
    String method,
    String path, {
    Map<String, Object?>? body,
    String? token,
  }) async {
    final request = http.Request(method, _baseUrl.resolve(path))
      ..headers['accept'] = 'application/json';
    if (body != null) {
      request
        ..headers['content-type'] = 'application/json'
        ..body = jsonEncode(body);
    }
    if (token != null) request.headers['authorization'] = 'Bearer $token';

    final http.Response response;
    try {
      response = await http.Response.fromStream(
        await _client.send(request),
      ).timeout(_timeout);
    } on http.ClientException {
      throw const ServerUnreachableException();
    } on SocketException {
      throw const ServerUnreachableException();
    } on TimeoutException {
      throw const ServerUnreachableException();
    }

    final status = response.statusCode;
    if (status == 204) return null;
    final json = _decode(response.body);
    if (status >= 200 && status < 300) return json;
    throw switch (json?['error']) {
      'invalid_email' => const InvalidEmailException(),
      'password_too_short' => const PasswordTooShortException(),
      'password_too_long' => const PasswordTooLongException(),
      'email_taken' => const EmailTakenException(),
      'invalid_credentials' => const InvalidCredentialsException(),
      'invalid_refresh_token' => const InvalidRefreshTokenException(),
      'unauthorized' => const AccessTokenRejectedException(),
      _ => const UnexpectedResponseException(),
    };
  }

  static Map<String, Object?>? _decode(String body) {
    try {
      final json = jsonDecode(body);
      return json is Map<String, Object?> ? json : null;
    } on FormatException {
      return null;
    }
  }

  static String _string(Map<String, Object?>? json, String key) =>
      switch (json?[key]) {
        final String value => value,
        _ => throw const UnexpectedResponseException(),
      };
}
