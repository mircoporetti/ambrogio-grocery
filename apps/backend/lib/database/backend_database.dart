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

@DataClassName('RecipeRow')
@TableIndex(
  name: 'recipes_account_cursor',
  columns: {#accountId, #changeCursor},
  unique: true,
)
class Recipes extends Table {
  UuidColumn get accountId => customType(
    PgTypes.uuid,
  ).references(Accounts, #id, onDelete: KeyAction.cascade)();
  UuidColumn get id => customType(PgTypes.uuid)();
  TimestampColumn get updatedAt => customType(PgTypes.timestampWithTimezone)();
  Column<Object> get recipe => customType(PgTypes.jsonb).nullable()();
  IntColumn get changeCursor => integer()();

  @override
  Set<Column> get primaryKey => {accountId, id};
}

@DataClassName('GroceryListRow')
@TableIndex(
  name: 'grocery_lists_account_cursor',
  columns: {#accountId, #changeCursor},
  unique: true,
)
class GroceryLists extends Table {
  UuidColumn get accountId => customType(
    PgTypes.uuid,
  ).references(Accounts, #id, onDelete: KeyAction.cascade)();
  TextColumn get week => text()();
  TimestampColumn get updatedAt => customType(PgTypes.timestampWithTimezone)();
  // Null once deleted: the row stays so other devices learn about it.
  Column<Object> get list => customType(PgTypes.jsonb).nullable()();
  IntColumn get changeCursor => integer()();

  @override
  Set<Column> get primaryKey => {accountId, week};
}

@DriftDatabase(
  tables: [Accounts, Sessions, RefreshTokens, Recipes, GroceryLists],
)
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
  int get schemaVersion => 3;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onUpgrade: (m, from, to) async {
      if (from < 2) {
        await m.createTable(recipes);
        await m.createIndex(recipesAccountCursor);
      }
      if (from < 3) {
        await m.createTable(groceryLists);
        await m.createIndex(groceryListsAccountCursor);
      }
    },
  );
}
