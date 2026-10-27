import 'dart:convert';

import 'account_exceptions.dart';

class Password {
  Password(this.value) {
    if (value.runes.length < minLength) throw const PasswordTooShortException();
    if (utf8.encode(value).length > maxBytes) {
      throw const PasswordTooLongException();
    }
  }

  static const minLength = 8;

  /// bcrypt only reads the first 72 bytes: longer passwords would silently
  /// match any password with the same start.
  static const maxBytes = 72;

  final String value;

  @override
  String toString() => 'Password(***)';
}
