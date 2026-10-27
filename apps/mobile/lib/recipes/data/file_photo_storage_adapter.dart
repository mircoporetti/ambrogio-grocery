import 'dart:io';

import '../domain/photo.dart';
import '../domain/photo_storage_port.dart';

class FilePhotoStorageAdapter implements PhotoStoragePort {
  @override
  Future<void> delete(Photo photo) async {
    final path = photo.path;
    if (path == null) return;
    final file = File(path);
    if (await file.exists()) await file.delete();
  }
}
