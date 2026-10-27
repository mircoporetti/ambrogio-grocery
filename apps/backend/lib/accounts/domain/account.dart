import 'account_id.dart';
import 'email.dart';

class Account {
  Account({AccountId? id, required this.email, required this.passwordHash})
    : id = id ?? AccountId.generate();

  final AccountId id;
  final Email email;
  final String passwordHash;
}
