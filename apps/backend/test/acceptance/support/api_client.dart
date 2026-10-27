import 'dart:convert';
import 'dart:io';

import 'package:ambrogio_backend/server.dart';
import 'package:http/http.dart' as http;
import 'package:test/test.dart';

class ApiClient {
  ApiClient._(this._server);

  final HttpServer _server;
  final _http = http.Client();

  static Future<ApiClient> start() async {
    final client = ApiClient._(await startServer(port: 0));
    addTearDown(client._close);
    return client;
  }

  Uri _uri(String path) =>
      Uri.parse('http://${_server.address.host}:${_server.port}$path');

  Future<ApiResponse> get(String path) async =>
      ApiResponse(await _http.get(_uri(path)));

  Future<void> _close() async {
    _http.close();
    await _server.close(force: true);
  }
}

class ApiResponse {
  ApiResponse(this._response);

  final http.Response _response;

  int get status => _response.statusCode;

  Object? get json => jsonDecode(_response.body);
}
