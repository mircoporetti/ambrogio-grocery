import 'package:ambrogio_grocery/account/domain/account_api_port.dart';
import 'package:ambrogio_grocery/account/domain/account_exceptions.dart';
import 'package:ambrogio_grocery/account/domain/auth_tokens.dart';

/// Follows the backend's rules for the cases the app tests drive.
class FakeAccountApiAdapter implements AccountApiPort {
  final _passwords = <String, String>{};
  final _emailsByAccessToken = <String, String>{};
  final loggedOut = <String>[];
  var _logins = 0;
  bool unreachable = false;

  void givenAccount(String email, String password) =>
      _passwords[email] = password;

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
    _logins++;
    final tokens = AuthTokens(
      access: 'access-$_logins',
      refresh: 'refresh-$_logins',
    );
    _emailsByAccessToken[tokens.access] = address;
    return tokens;
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
    loggedOut.add(refreshToken);
  }

  void _reach() {
    if (unreachable) throw const ServerUnreachableException();
  }
}
