import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';

import '../../http/json.dart';
import '../application/authenticate.dart';
import '../application/get_account.dart';
import '../application/log_in.dart';
import '../application/log_out.dart';
import '../application/refresh_session.dart';
import '../application/register_account.dart';
import '../application/session_tokens.dart';
import '../domain/access_token.dart';
import '../domain/account.dart';
import '../domain/account_exceptions.dart';

class AccountRoutes {
  AccountRoutes(
    this._registerAccount,
    this._logIn,
    this._refreshSession,
    this._logOut,
    this._authenticate,
    this._getAccount,
  );

  final RegisterAccount _registerAccount;
  final LogIn _logIn;
  final RefreshSession _refreshSession;
  final LogOut _logOut;
  final Authenticate _authenticate;
  final GetAccount _getAccount;

  Router get router => Router()
    ..post('/accounts', _guard(_register))
    ..post('/sessions', _guard(_startSession))
    ..post('/sessions/refresh', _guard(_refresh))
    ..post('/sessions/logout', _guard(_endSession))
    ..get('/me', _guard(_me));

  Future<Response> _register(Request request) async {
    final fields = await readStringFields(request, ['email', 'password']);
    final account = await _registerAccount(
      email: fields['email']!,
      password: fields['password']!,
    );
    return jsonResponse(201, _accountJson(account));
  }

  Future<Response> _startSession(Request request) async {
    final fields = await readStringFields(request, ['email', 'password']);
    final tokens = await _logIn(
      email: fields['email']!,
      password: fields['password']!,
    );
    return _tokensResponse(tokens);
  }

  Future<Response> _refresh(Request request) async {
    final fields = await readStringFields(request, ['refreshToken']);
    return _tokensResponse(await _refreshSession(fields['refreshToken']!));
  }

  Future<Response> _endSession(Request request) async {
    final fields = await readStringFields(request, ['refreshToken']);
    await _logOut(fields['refreshToken']!);
    return Response(204);
  }

  Future<Response> _me(Request request) async {
    final accountId = _authenticate(bearerToken(request));
    return jsonResponse(200, _accountJson(await _getAccount(accountId)));
  }

  Response _tokensResponse(SessionTokens tokens) => jsonResponse(
    200,
    {
      'tokenType': 'Bearer',
      'accessToken': tokens.access.value,
      'expiresIn': AccessToken.lifetime.inSeconds,
      'refreshToken': tokens.refresh.value,
    },
    headers: {'cache-control': 'no-store'},
  );

  Map<String, Object?> _accountJson(Account account) => {
    'id': account.id.value,
    'email': account.email.value,
  };

  Handler _guard(Handler handler) => (request) async {
    try {
      return await handler(request);
    } on InvalidRequestException {
      return errorResponse(400, 'invalid_request');
    } on AccountException catch (e) {
      return switch (e) {
        InvalidEmailException() => errorResponse(400, 'invalid_email'),
        PasswordTooShortException() => errorResponse(400, 'password_too_short'),
        PasswordTooLongException() => errorResponse(400, 'password_too_long'),
        EmailTakenException() => errorResponse(409, 'email_taken'),
        InvalidCredentialsException() => errorResponse(
          401,
          'invalid_credentials',
        ),
        InvalidRefreshTokenException() => errorResponse(
          401,
          'invalid_refresh_token',
        ),
        NotAuthenticatedException() => errorResponse(
          401,
          'unauthorized',
          headers: {'www-authenticate': 'Bearer'},
        ),
      };
    }
  };
}
