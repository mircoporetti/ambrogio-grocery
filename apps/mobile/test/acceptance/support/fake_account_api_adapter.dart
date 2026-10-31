import 'package:ambrogio_grocery/account/domain/account_api_port.dart';
import 'package:ambrogio_grocery/account/domain/account_exceptions.dart';
import 'package:ambrogio_grocery/account/domain/auth_tokens.dart';

/// Follows the backend's rules for the cases the app tests drive.
class FakeAccountApiAdapter implements AccountApiPort {
  /// With [refreshInCookie] it acts like a browser and the server together:
  /// the refresh token stays in a cookie the app never sees.
  FakeAccountApiAdapter({this.refreshInCookie = false});

  final bool refreshInCookie;
  String? _cookie;

  bool get hasCookieSession => _emailsByRefreshToken.containsKey(_cookie);
  final _passwords = <String, String>{};
  final _emailsByAccessToken = <String, String>{};
  final _emailsByRefreshToken = <String, String>{};
  final loggedOut = <String>[];
  var _issued = 0;
  bool unreachable = false;

  void givenAccount(String email, String password) =>
      _passwords[email] = password;

  String? emailFor(String accessToken) => _emailsByAccessToken[accessToken];

  void expireAccessTokens() => _emailsByAccessToken.clear();

  void expireSessions() {
    _emailsByAccessToken.clear();
    _emailsByRefreshToken.clear();
  }

  @override
  Future<void> register({
    required String email,
    required String password,
  }) async {
    _reach();
    final address = email.trim().toLowerCase();
    if (!RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(address)) {
      throw const InvalidEmailException();
    }
    if (password.length < 8) throw const PasswordTooShortException();
    if (_passwords.containsKey(address)) throw const EmailTakenException();
    _passwords[address] = password;
  }

  @override
  Future<AuthTokens> logIn({
    required String email,
    required String password,
  }) async {
    _reach();
    final address = email.trim().toLowerCase();
    if (_passwords[address] != password) {
      throw const InvalidCredentialsException();
    }
    return _issue(address);
  }

  @override
  Future<AuthTokens> refresh(String refreshToken) async {
    _reach();
    final email =
        _emailsByRefreshToken.remove(
          refreshInCookie ? _cookie : refreshToken,
        ) ??
        (throw const InvalidRefreshTokenException());
    return _issue(email);
  }

  @override
  Future<String> currentEmail(String accessToken) async {
    _reach();
    return _emailsByAccessToken[accessToken] ??
        (throw const UnexpectedResponseException());
  }

  @override
  Future<void> logOut(String refreshToken) async {
    _reach();
    final token = refreshInCookie ? _cookie : refreshToken;
    _emailsByRefreshToken.remove(token);
    _cookie = null;
    loggedOut.add(token!);
  }

  AuthTokens _issue(String email) {
    _issued++;
    final tokens = AuthTokens(
      access: 'access-$_issued',
      refresh: 'refresh-$_issued',
    );
    _emailsByAccessToken[tokens.access] = email;
    _emailsByRefreshToken[tokens.refresh] = email;
    if (!refreshInCookie) return tokens;
    _cookie = tokens.refresh;
    return AuthTokens(access: tokens.access, refresh: '');
  }

  void _reach() {
    if (unreachable) throw const ServerUnreachableException();
  }
}
