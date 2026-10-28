import 'dart:io';

import 'package:ambrogio_backend/photos/data/photo_storage_config.dart';
import 'package:ambrogio_backend/photos/data/s3_photo_storage_adapter.dart';
import 'package:http/http.dart' as http;
import 'package:test/test.dart';

Future<S3PhotoStorageAdapter> openTestPhotoStorage() async {
  await _storageReady;
  final config = photoStorageConfig({
    ...Platform.environment,
    'S3_BUCKET': Platform.environment['S3_BUCKET'] ?? 'ambrogio-photos-test',
  });
  final storage = S3PhotoStorageAdapter(config.signer, bucket: config.bucket);
  addTearDown(storage.close);
  return storage;
}

final _endpoint = Uri.parse(
  Platform.environment['S3_ENDPOINT'] ?? 'http://localhost:8333',
);

final Future<void> _storageReady = _startStorageIfNeeded();

Future<void> _startStorageIfNeeded() async {
  if (await _isUp()) return;
  if (Platform.environment.containsKey('S3_ENDPOINT')) {
    throw StateError('No photo storage at S3_ENDPOINT=$_endpoint');
  }
  final compose = await Process.run('docker', [
    'compose',
    'up',
    '--detach',
    '--wait',
  ]);
  for (var attempt = 0; attempt < 30; attempt++) {
    if (await _isUp()) return;
    await Future<void>.delayed(const Duration(seconds: 1));
  }
  throw StateError(
    'Could not start the test photo storage with `docker compose up` '
    '(is Docker running?):\n${compose.stderr}',
  );
}

Future<bool> _isUp() async {
  try {
    final response = await http
        .get(_endpoint.resolve('/healthz'))
        .timeout(const Duration(seconds: 2));
    return response.statusCode == 200;
  } on Exception {
    return false;
  }
}
