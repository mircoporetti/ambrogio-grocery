import 'account.dart';
import 'account_id.dart';
import 'email.dart';

abstract interface class AccountStoragePort {
  Future<void> save(Account account);

  Future<Account?> findById(AccountId id);

  Future<Account?> findByEmail(Email email);
}
