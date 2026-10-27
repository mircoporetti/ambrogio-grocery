import 'auth_tokens.dart';

abstract interface class AccountApiPort {
  Future<void> register({required String email, required String password});

  Future<AuthTokens> logIn({required String email, required String password});

  Future<String> currentEmail(String accessToken);

  Future<void> logOut(String refreshToken);
}
