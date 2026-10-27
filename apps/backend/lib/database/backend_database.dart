import 'package:drift/drift.dart';
import 'package:drift_postgres/drift_postgres.dart';
import 'package:postgres/postgres.dart' as pg;

part 'backend_database.g.dart';

@DataClassName('AccountRow')
class Accounts extends Table {
  UuidColumn get id => customType(PgTypes.uuid)();
  TextColumn get email => text().unique()();
  TextColumn get passwordHash => text()();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('SessionRow')
class Sessions extends Table {
  UuidColumn get id => customType(PgTypes.uuid)();
  UuidColumn get accountId => customType(
    PgTypes.uuid,
  ).references(Accounts, #id, onDelete: KeyAction.cascade)();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('RefreshTokenRow')
class RefreshTokens extends Table {
  TextColumn get tokenHash => text()();
  UuidColumn get sessionId => customType(
    PgTypes.uuid,
  ).references(Sessions, #id, onDelete: KeyAction.cascade)();
  TimestampColumn get expiresAt => customType(PgTypes.timestampWithTimezone)();
  BoolColumn get used => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {tokenHash};
}

@DriftDatabase(tables: [Accounts, Sessions, RefreshTokens])
class BackendDatabase extends _$BackendDatabase {
  BackendDatabase(super.executor);

  BackendDatabase.connect(pg.Endpoint endpoint, {required pg.SslMode sslMode})
    : super(
        PgDatabase(
          endpoint: endpoint,
          settings: pg.ConnectionSettings(sslMode: sslMode),
        ),
      );

  @override
  int get schemaVersion => 1;
}
