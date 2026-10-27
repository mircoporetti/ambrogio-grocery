import '../domain/account.dart';
import '../domain/account_exceptions.dart';
import '../domain/account_storage_port.dart';
import '../domain/email.dart';
import '../domain/password.dart';
import '../domain/password_hasher_port.dart';

class RegisterAccount {
  RegisterAccount(this._accounts, this._hasher);

  final AccountStoragePort _accounts;
  final PasswordHasherPort _hasher;

  Future<Account> call({
    required String email,
    required String password,
  }) async {
    final address = Email(email);
    final chosen = Password(password);
    if (await _accounts.findByEmail(address) != null) {
      throw const EmailTakenException();
    }
    final account = Account(
      email: address,
      passwordHash: await _hasher.hash(chosen),
    );
    await _accounts.save(account);
    return account;
  }
}
