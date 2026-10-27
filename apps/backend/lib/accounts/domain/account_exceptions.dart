sealed class AccountException implements Exception {
  const AccountException();
}

class InvalidEmailException extends AccountException {
  const InvalidEmailException();
}

class PasswordTooShortException extends AccountException {
  const PasswordTooShortException();
}

class PasswordTooLongException extends AccountException {
  const PasswordTooLongException();
}

class EmailTakenException extends AccountException {
  const EmailTakenException();
}

class InvalidCredentialsException extends AccountException {
  const InvalidCredentialsException();
}

class NotAuthenticatedException extends AccountException {
  const NotAuthenticatedException();
}

class InvalidRefreshTokenException extends AccountException {
  const InvalidRefreshTokenException();
}
