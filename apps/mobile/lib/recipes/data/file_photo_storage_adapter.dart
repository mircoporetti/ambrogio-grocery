import 'dart:io';

import '../domain/photo_storage_port.dart';

class FilePhotoStorageAdapter implements PhotoStoragePort {
  @override
  Future<void> delete(String path) async {
    final file = File(path);
    if (await file.exists()) await file.delete();
  }
}
