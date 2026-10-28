import '../domain/access_token_port.dart';
import '../domain/account_exceptions.dart';
import '../domain/account_id.dart';
import '../../shared/domain/clock_port.dart';

class Authenticate {
  Authenticate(this._accessTokens, this._clock);

  final AccessTokenPort _accessTokens;
  final ClockPort _clock;

  AccountId call(String? token) {
    if (token == null || token.isEmpty) throw const NotAuthenticatedException();
    return _accessTokens.verify(token, _clock.now()) ??
        (throw const NotAuthenticatedException());
  }
}
