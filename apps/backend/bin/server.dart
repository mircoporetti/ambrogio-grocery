import 'dart:io';

import 'package:ambrogio_backend/accounts/data/bcrypt_password_hasher_adapter.dart';
import 'package:ambrogio_backend/accounts/data/jwt_access_token_adapter.dart';
import 'package:ambrogio_backend/accounts/data/system_clock_adapter.dart';
import 'package:ambrogio_backend/database/backend_database.dart';
import 'package:ambrogio_backend/database/database_config.dart';
import 'package:ambrogio_backend/server.dart';

Future<void> main() async {
  final env = Platform.environment;
  final jwtSecret = env['JWT_SECRET'];
  if (jwtSecret == null) {
    stderr.writeln('Set JWT_SECRET: at least 32 random bytes.');
    exit(64);
  }
  final database = BackendDatabase.connect(
    databaseEndpoint(env),
    sslMode: databaseSslMode(env),
  );
  final server = await startServer(
    port: int.parse(env['PORT'] ?? '8080'),
    address: InternetAddress.anyIPv4,
    database: database,
    clock: SystemClockAdapter(),
    passwordHasher: BcryptPasswordHasherAdapter(),
    accessTokens: JwtAccessTokenAdapter(jwtSecret),
  );
  stdout.writeln('Listening on port ${server.port}');
}
