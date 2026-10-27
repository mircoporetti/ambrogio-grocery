import 'package:postgres/postgres.dart' as pg;

pg.Endpoint databaseEndpoint(Map<String, String> env) => pg.Endpoint(
  host: env['DB_HOST'] ?? 'localhost',
  port: int.parse(env['DB_PORT'] ?? '5433'),
  database: env['DB_NAME'] ?? 'ambrogio',
  username: env['DB_USER'] ?? 'ambrogio',
  password: env['DB_PASSWORD'] ?? 'ambrogio',
);

pg.SslMode databaseSslMode(Map<String, String> env) {
  final local = [
    'localhost',
    '127.0.0.1',
  ].contains(env['DB_HOST'] ?? 'localhost');
  return switch (env['DB_SSL'] ?? (local ? 'disable' : 'require')) {
    'disable' => pg.SslMode.disable,
    _ => pg.SslMode.require,
  };
}
