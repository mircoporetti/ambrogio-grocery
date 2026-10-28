import 'dart:io';

import 'package:path/path.dart' as p;

import '../domain/photo.dart';
import '../domain/photo_file.dart';
import '../domain/photo_id.dart';
import '../domain/photo_storage_port.dart';
import 'photo_content_types.dart';

class FilePhotoStorageAdapter implements PhotoStoragePort {
  FilePhotoStorageAdapter(this._documentsDir);

  final String _documentsDir;

  @override
  Future<PhotoFile?> read(Photo photo) async {
    final path = photo.path;
    if (path == null) return null;
    final file = File(path);
    if (!await file.exists()) return null;
    final bytes = await file.readAsBytes();
    if (bytes.isEmpty) return null;
    return PhotoFile(bytes: bytes, contentType: photoContentTypeOf(path));
  }

  @override
  Future<String> save(PhotoId id, PhotoFile file) async {
    final photos = Directory(p.join(_documentsDir, 'photos'));
    await photos.create(recursive: true);
    final target = File(
      p.join(photos.path, '${id.value}${photoExtensionFor(file.contentType)}'),
    );
    await target.writeAsBytes(file.bytes, flush: true);
    return target.path;
  }

  @override
  Future<void> delete(Photo photo) async {
    final path = photo.path;
    if (path == null) return;
    final file = File(path);
    if (await file.exists()) await file.delete();
  }
}
