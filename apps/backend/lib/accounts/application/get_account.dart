import '../domain/account.dart';
import '../domain/account_exceptions.dart';
import '../domain/account_id.dart';
import '../domain/account_storage_port.dart';

class GetAccount {
  GetAccount(this._accounts);

  final AccountStoragePort _accounts;

  Future<Account> call(AccountId id) async =>
      await _accounts.findById(id) ?? (throw const NotAuthenticatedException());
}
