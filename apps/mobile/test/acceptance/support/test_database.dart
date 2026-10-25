import 'dart:io';

import 'package:ambrogio_grocery/database/app_database.dart';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

const testDocumentsDir = '/app-documents';

AppDatabase openInMemoryDatabase() {
  final db = AppDatabase(_forTests(NativeDatabase.memory()));
  addTearDown(db.close);
  return db;
}

File newDatabaseFile() {
  final dir = Directory.systemTemp.createTempSync('ambrogio_test_');
  addTearDown(() => dir.deleteSync(recursive: true));
  return File('${dir.path}/app.sqlite');
}

AppDatabase openFileDatabase(File file) =>
    AppDatabase(_forTests(NativeDatabase(file)));

/// By default drift waits one event-loop turn before closing a query stream
/// nobody listens to. That leaves a timer pending when a widget test ends,
/// which the test framework rejects, so close streams right away in tests.
DatabaseConnection _forTests(QueryExecutor executor) =>
    DatabaseConnection(executor, closeStreamsSynchronously: true);
