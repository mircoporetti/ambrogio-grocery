import 'api_client.dart';


class WebSessionsApi {
  WebSessionsApi(this._api, {this.origin = webOrigin});

  static const webOrigin = ApiClient.webOrigin;

  final ApiClient _api;
  final String origin;
  String? cookie;

  Future<ApiResponse> logIn(String email, String password) =>
      _send('POST', '/sessions', body: {'email': email, 'password': password});

  Future<ApiResponse> refresh() => _send('POST', '/sessions/refresh', body: {});

  Future<ApiResponse> logOut() => _send('POST', '/sessions/logout', body: {});

  Future<ApiResponse> preflight(String path, String method) => _api.send(
    'OPTIONS',
    path,
    headers: {
      'origin': origin,
      'access-control-request-method': method,
      'access-control-request-headers': 'authorization, content-type',
    },
  );

  Future<ApiResponse> _send(String method, String path, {Object? body}) async {
    final response = await _api.send(
      method,
      path,
      body: body,
      headers: {'origin': origin, 'cookie': ?cookie},
    );
    final setCookie = response.header('set-cookie');
    if (setCookie != null) {
      final value = setCookie.split(';').first;
      cookie = value.endsWith('=') ? null : value;
    }
    return response;
  }
}
