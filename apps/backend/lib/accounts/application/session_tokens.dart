import '../domain/access_token.dart';
import '../domain/refresh_token.dart';

class SessionTokens {
  SessionTokens({required this.access, required this.refresh});

  final AccessToken access;
  final RefreshToken refresh;
}
