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

class ServerUnreachableException extends AccountException {
  const ServerUnreachableException();
}

class UnexpectedResponseException extends AccountException {
  const UnexpectedResponseException();
}
