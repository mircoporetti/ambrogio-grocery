import '../../l10n/app_localizations.dart';
import '../domain/account_exceptions.dart';

enum AccountError {
  invalidCredentials,
  emailTaken,
  invalidEmail,
  passwordTooShort,
  passwordTooLong,
  serverUnreachable,
  unexpected;

  static AccountError from(Exception e) => switch (e) {
    InvalidCredentialsException() => invalidCredentials,
    EmailTakenException() => emailTaken,
    InvalidEmailException() => invalidEmail,
    PasswordTooShortException() => passwordTooShort,
    PasswordTooLongException() => passwordTooLong,
    ServerUnreachableException() => serverUnreachable,
    _ => unexpected,
  };

  String message(AppLocalizations l10n) => switch (this) {
    invalidCredentials => l10n.invalidCredentials,
    emailTaken => l10n.emailTaken,
    invalidEmail => l10n.invalidEmail,
    passwordTooShort => l10n.passwordTooShort,
    passwordTooLong => l10n.passwordTooLong,
    serverUnreachable => l10n.serverUnreachable,
    unexpected => l10n.somethingWentWrong,
  };
}
