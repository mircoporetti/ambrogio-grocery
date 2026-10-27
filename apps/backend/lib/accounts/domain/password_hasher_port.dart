import 'password.dart';

abstract interface class PasswordHasherPort {
  Future<String> hash(Password password);

  Future<bool> verify(String password, String hash);
}
