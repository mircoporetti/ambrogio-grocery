import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';

import '../../http/cors.dart';
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
import '../domain/refresh_token.dart';

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
    return _tokensResponse(request, tokens);
  }

  Future<Response> _refresh(Request request) async => _tokensResponse(
    request,
    await _refreshSession(await _refreshToken(request)),
  );

  Future<Response> _endSession(Request request) async {
    await _logOut(await _refreshToken(request));
    if (!isFromWebApp(request)) return Response(204);
    return Response(204, headers: {'set-cookie': _refreshCookie('', 0)});
  }

  // The web app never sees its refresh token: it lives in an httpOnly cookie
  // only the session endpoints receive. The phone app keeps it in the body.
  Future<String> _refreshToken(Request request) async {
    if (!isFromWebApp(request)) {
      final fields = await readStringFields(request, ['refreshToken']);
      return fields['refreshToken']!;
    }
    for (final cookie in (request.headers['cookie'] ?? '').split(';')) {
      final [name, ...value] = cookie.trim().split('=');
      if (name == _cookieName) return value.join('=');
    }
    return '';
  }

  static const _cookieName = 'ambrogio_refresh';

  static String _refreshCookie(String value, int maxAge) =>
      '$_cookieName=$value; Max-Age=$maxAge; Path=/sessions; HttpOnly; '
      'Secure; SameSite=Strict';

  Future<Response> _me(Request request) async {
    final accountId = _authenticate(bearerToken(request));
    return jsonResponse(200, _accountJson(await _getAccount(accountId)));
  }

  Response _tokensResponse(Request request, SessionTokens tokens) {
    final web = isFromWebApp(request);
    return jsonResponse(
      200,
      {
        'tokenType': 'Bearer',
        'accessToken': tokens.access.value,
        'expiresIn': AccessToken.lifetime.inSeconds,
        if (!web) 'refreshToken': tokens.refresh.value,
      },
      headers: {
        'cache-control': 'no-store',
        if (web)
          'set-cookie': _refreshCookie(
            tokens.refresh.value,
            RefreshToken.lifetime.inSeconds,
          ),
      },
    );
  }

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
