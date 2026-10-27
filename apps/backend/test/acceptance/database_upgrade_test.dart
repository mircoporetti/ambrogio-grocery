import 'package:bcrypt/bcrypt.dart';
import 'package:postgres/postgres.dart' as pg;
import 'package:test/test.dart';

import 'support/accounts_api.dart';
import 'support/api_client.dart';
import 'support/recipes_api.dart';
import 'support/test_database.dart';

void main() {
  test(
    'accounts survive the upgrade from schema 1 and can sync recipes',
    () async {
      final endpoint = await newTestDatabase();
      final connection = await pg.Connection.open(
        endpoint,
        settings: const pg.ConnectionSettings(sslMode: pg.SslMode.disable),
      );
      try {
        await _createSchema1(connection);
        await connection.execute(
          pg.Sql.named(
            'INSERT INTO accounts (id, email, password_hash) '
            'VALUES (@id::uuid, @email, @hash)',
          ),
          parameters: {
            'id': '5e2b7c1a-9d3f-4a6b-8c5d-1e2f3a4b5c6d',
            'email': 'ada@example.com',
            'hash': BCrypt.hashpw('pw-ada-1', BCrypt.gensalt(logRounds: 4)),
          },
        );
      } finally {
        await connection.close();
      }

      final api = await ApiClient.start(database: openDatabaseAt(endpoint));
      final ada = await AccountsApi(
        api,
      ).logInTokens('ada@example.com', 'pw-ada-1');
      final recipes = RecipesApi(api);
      final change = upsert(
        '0b9e4c1d-2f3a-4b5c-8d6e-7f8091a2b3c4',
        salad,
        at: DateTime.utc(2026, 10, 20),
      );

      expect((await recipes.push(ada.access, [change])).status, 204);
      expect(await recipes.pullChanges(ada.access), [change]);
    },
  );
}

Future<void> _createSchema1(pg.Connection db) async {
  for (final sql in [
    'CREATE TABLE accounts ('
        'id uuid NOT NULL PRIMARY KEY, '
        'email text NOT NULL UNIQUE, '
        'password_hash text NOT NULL)',
    'CREATE TABLE sessions ('
        'id uuid NOT NULL PRIMARY KEY, '
        'account_id uuid NOT NULL REFERENCES accounts (id) ON DELETE CASCADE)',
    'CREATE TABLE refresh_tokens ('
        'token_hash text NOT NULL PRIMARY KEY, '
        'session_id uuid NOT NULL REFERENCES sessions (id) ON DELETE CASCADE, '
        'expires_at timestamp with time zone NOT NULL, '
        'used boolean NOT NULL DEFAULT FALSE)',
    'CREATE TABLE __schema (version integer NOT NULL DEFAULT 0)',
    'INSERT INTO __schema (version) VALUES (1)',
  ]) {
    await db.execute(sql);
  }
}
