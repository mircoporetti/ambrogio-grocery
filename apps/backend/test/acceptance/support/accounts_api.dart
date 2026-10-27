import 'api_client.dart';

typedef Tokens = ({String access, String refresh});

class AccountsApi {
  AccountsApi(this._api);

  final ApiClient _api;

  Future<ApiResponse> register(String email, String password) =>
      _api.post('/accounts', {'email': email, 'password': password});

  Future<ApiResponse> logIn(String email, String password) =>
      _api.post('/sessions', {'email': email, 'password': password});

  Future<Tokens> logInTokens(String email, String password) async =>
      _tokens(await logIn(email, password));

  Future<Tokens> registerAndLogIn(String email, String password) async {
    await register(email, password);
    return logInTokens(email, password);
  }

  Future<ApiResponse> refresh(String refreshToken) =>
      _api.post('/sessions/refresh', {'refreshToken': refreshToken});

  Future<Tokens> refreshTokens(String refreshToken) async =>
      _tokens(await refresh(refreshToken));

  Future<ApiResponse> me(String? accessToken) =>
      _api.get('/me', token: accessToken);

  Future<ApiResponse> logOut(String refreshToken) =>
      _api.post('/sessions/logout', {'refreshToken': refreshToken});

  Tokens _tokens(ApiResponse response) => (
    access: response['accessToken']! as String,
    refresh: response['refreshToken']! as String,
  );
}
