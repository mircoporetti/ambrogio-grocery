import 'dart:convert';
import 'dart:isolate';

import 'package:bcrypt/bcrypt.dart';

import '../domain/password.dart';
import '../domain/password_hasher_port.dart';

class BcryptPasswordHasherAdapter implements PasswordHasherPort {
  BcryptPasswordHasherAdapter({this.cost = 12});

  final int cost;

  // bcrypt is slow on purpose; an isolate keeps other requests moving.
  @override
  Future<String> hash(Password password) {
    final cost = this.cost;
    return Isolate.run(
      () => BCrypt.hashpw(password.value, BCrypt.gensalt(logRounds: cost)),
    );
  }

  @override
  Future<bool> verify(String password, String hash) async {
    if (utf8.encode(password).length > Password.maxBytes) return false;
    return Isolate.run(() {
      try {
        return BCrypt.checkpw(password, hash);
      } on ArgumentError {
        return false;
      }
    });
  }
}
