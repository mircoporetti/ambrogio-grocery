import 'package:drift_postgres/drift_postgres.dart';
import 'package:postgres/postgres.dart' as pg;

import '../../database/backend_database.dart';
import '../domain/account.dart';
import '../domain/account_exceptions.dart';
import '../domain/account_id.dart';
import '../domain/account_storage_port.dart';
import '../domain/email.dart';

class DriftAccountStorageAdapter implements AccountStoragePort {
  DriftAccountStorageAdapter(this._db);

  final BackendDatabase _db;

  static const _uniqueViolation = '23505';

  @override
  Future<void> save(Account account) async {
    try {
      await _db
          .into(_db.accounts)
          .insert(
            AccountsCompanion.insert(
              id: UuidValue.fromString(account.id.value),
              email: account.email.value,
              passwordHash: account.passwordHash,
            ),
          );
    } on pg.ServerException catch (e) {
      // Two registrations with the same email can both pass the check in
      // RegisterAccount; the unique index lets only one of them in.
      if (e.code == _uniqueViolation) throw const EmailTakenException();
      rethrow;
    }
  }

  @override
  Future<Account?> findById(AccountId id) async {
    final row =
        await (_db.select(_db.accounts)
              ..where((a) => a.id.equals(UuidValue.fromString(id.value))))
            .getSingleOrNull();
    return row == null ? null : _toAccount(row);
  }

  @override
  Future<Account?> findByEmail(Email email) async {
    final row = await (_db.select(
      _db.accounts,
    )..where((a) => a.email.equals(email.value))).getSingleOrNull();
    return row == null ? null : _toAccount(row);
  }

  Account _toAccount(AccountRow row) => Account(
    id: AccountId(row.id.uuid),
    email: Email(row.email),
    passwordHash: row.passwordHash,
  );
}
