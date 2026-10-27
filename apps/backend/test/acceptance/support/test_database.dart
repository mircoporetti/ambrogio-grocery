import 'dart:io';

import 'package:ambrogio_backend/database/backend_database.dart';
import 'package:ambrogio_backend/database/database_config.dart';
import 'package:postgres/postgres.dart' as pg;
import 'package:test/test.dart';
import 'package:uuid/uuid.dart';

Future<pg.Endpoint> newTestDatabase() async {
  await _serverReady;
  final name = 'test_${const Uuid().v4().replaceAll('-', '')}';
  await _onServer('CREATE DATABASE $name');
  addTearDown(() => _onServer('DROP DATABASE IF EXISTS $name WITH (FORCE)'));
  final server = _server;
  return pg.Endpoint(
    host: server.host,
    port: server.port,
    database: name,
    username: server.username,
    password: server.password,
  );
}

BackendDatabase openDatabaseAt(pg.Endpoint endpoint) {
  final db = BackendDatabase.connect(endpoint, sslMode: pg.SslMode.disable);
  addTearDown(db.close);
  return db;
}

Future<BackendDatabase> openTestDatabase() async =>
    openDatabaseAt(await newTestDatabase());

final _server = databaseEndpoint(Platform.environment);

final Future<void> _serverReady = _startServerIfNeeded();

Future<void> _startServerIfNeeded() async {
  if (await _canConnect()) return;
  if (Platform.environment.containsKey('DB_HOST')) {
    throw StateError('No Postgres at DB_HOST=${_server.host}:${_server.port}');
  }
  final compose = await Process.run('docker', [
    'compose',
    'up',
    '--detach',
    '--wait',
  ]);
  // Other test files start it at the same time, and then this compose call
  // can fail even though the server comes up: wait for it either way.
  for (var attempt = 0; attempt < 30; attempt++) {
    if (await _canConnect()) return;
    await Future<void>.delayed(const Duration(seconds: 1));
  }
  throw StateError(
    'Could not start the test database with `docker compose up` '
    '(is Docker running?):\n${compose.stderr}',
  );
}

Future<bool> _canConnect() async {
  try {
    final connection = await _connect();
    await connection.close();
    return true;
  } on Exception {
    return false;
  }
}

Future<pg.Connection> _connect() => pg.Connection.open(
  _server,
  settings: const pg.ConnectionSettings(
    sslMode: pg.SslMode.disable,
    connectTimeout: Duration(seconds: 2),
  ),
);

Future<void> _onServer(String sql) async {
  final connection = await _connect();
  try {
    await connection.execute(sql);
  } finally {
    await connection.close();
  }
}
