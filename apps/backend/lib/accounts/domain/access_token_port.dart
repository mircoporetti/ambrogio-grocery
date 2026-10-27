import 'access_token.dart';
import 'account_id.dart';

abstract interface class AccessTokenPort {
  AccessToken issue(AccountId accountId, DateTime now);

  AccountId? verify(String token, DateTime now);
}
