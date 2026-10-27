import 'dart:convert';
import 'dart:io';

import 'package:ambrogio_backend/accounts/data/bcrypt_password_hasher_adapter.dart';
import 'package:ambrogio_backend/accounts/data/jwt_access_token_adapter.dart';
import 'package:ambrogio_backend/accounts/domain/clock_port.dart';
import 'package:ambrogio_backend/database/backend_database.dart';
import 'package:ambrogio_backend/server.dart';
import 'package:http/http.dart' as http;
import 'package:test/test.dart';

import 'fixed_clock_adapter.dart';
import 'test_database.dart';

class ApiClient {
  ApiClient._(this._server);

  final HttpServer _server;
  final _http = http.Client();
  bool _stopped = false;

  static Future<ApiClient> start({
    BackendDatabase? database,
    ClockPort? clock,
    String jwtSecret = 'test-signing-secret-of-at-least-32-bytes',
  }) async {
    final server = await startServer(
      port: 0,
      database: database ?? await openTestDatabase(),
      clock: clock ?? FixedClockAdapter(),
      passwordHasher: BcryptPasswordHasherAdapter(cost: 4),
      accessTokens: JwtAccessTokenAdapter(jwtSecret),
    );
    final client = ApiClient._(server);
    addTearDown(client.stop);
    return client;
  }

  Uri _uri(String path) =>
      Uri.parse('http://${_server.address.host}:${_server.port}$path');

  Map<String, String> _headers(String? token) => {
    'content-type': 'application/json',
    if (token != null) 'authorization': 'Bearer $token',
  };

  Future<ApiResponse> get(String path, {String? token}) async =>
      ApiResponse(await _http.get(_uri(path), headers: _headers(token)));

  Future<ApiResponse> post(String path, Object? body, {String? token}) =>
      postRaw(path, jsonEncode(body), token: token);

  Future<ApiResponse> postRaw(
    String path,
    String body, {
    String? token,
  }) async => ApiResponse(
    await _http.post(_uri(path), headers: _headers(token), body: body),
  );

  Future<ApiResponse> delete(String path, {String? token}) async =>
      ApiResponse(await _http.delete(_uri(path), headers: _headers(token)));

  Future<void> stop() async {
    if (_stopped) return;
    _stopped = true;
    _http.close();
    await _server.close(force: true);
  }
}

class ApiResponse {
  ApiResponse(this._response);

  final http.Response _response;

  int get status => _response.statusCode;

  Object? get json => jsonDecode(_response.body);

  Object? operator [](String key) => (json! as Map<String, Object?>)[key];

  String? header(String name) => _response.headers[name];
}
