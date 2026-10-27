import 'account_id.dart';
import 'session_id.dart';

class Session {
  Session({SessionId? id, required this.accountId})
    : id = id ?? SessionId.generate();

  final SessionId id;
  final AccountId accountId;
}
