import '../domain/access_token_port.dart';
import '../domain/account_exceptions.dart';
import '../domain/account_storage_port.dart';
import '../../shared/domain/clock_port.dart';
import '../domain/email.dart';
import '../domain/password.dart';
import '../domain/password_hasher_port.dart';
import '../domain/refresh_token.dart';
import '../domain/session.dart';
import '../domain/session_storage_port.dart';
import 'session_tokens.dart';

class LogIn {
  LogIn(
    this._accounts,
    this._sessions,
    this._hasher,
    this._accessTokens,
    this._clock,
  );

  final AccountStoragePort _accounts;
  final SessionStoragePort _sessions;
  final PasswordHasherPort _hasher;
  final AccessTokenPort _accessTokens;
  final ClockPort _clock;

  // Checked when the email is unknown, so that answer takes as long as a
  // wrong password and doesn't reveal which emails have an account.
  late final Future<String> _unknownAccountHash = _hasher.hash(
    Password('no-account-has-this-password'),
  );

  Future<SessionTokens> call({
    required String email,
    required String password,
  }) async {
    final Email address;
    try {
      address = Email(email);
    } on InvalidEmailException {
      throw const InvalidCredentialsException();
    }
    final account = await _accounts.findByEmail(address);
    final hash = account?.passwordHash ?? await _unknownAccountHash;
    final matches = await _hasher.verify(password, hash);
    if (account == null || !matches) throw const InvalidCredentialsException();

    final now = _clock.now();
    final session = Session(accountId: account.id);
    await _sessions.save(session);
    final refresh = RefreshToken.issue(session, now);
    await _sessions.saveRefreshToken(refresh);
    return SessionTokens(
      access: _accessTokens.issue(account.id, now),
      refresh: refresh,
    );
  }
}
