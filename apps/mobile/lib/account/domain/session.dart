import 'auth_tokens.dart';

class Session {
  Session({required this.email, required this.tokens});

  final String email;
  final AuthTokens tokens;
}
