import 'package:ambrogio_grocery/recipes/domain/photo.dart';
import 'package:ambrogio_grocery/recipes/domain/photo_file.dart';
import 'package:ambrogio_grocery/recipes/domain/photo_id.dart';
import 'package:ambrogio_grocery/recipes/domain/photo_storage_port.dart';

import 'test_database.dart';

class FakePhotoStorageAdapter implements PhotoStoragePort {
  FakePhotoStorageAdapter({this.documentsDir = testDocumentsDir});

  final String documentsDir;
  final _files = <String, List<int>>{};

  void givenFile(String path, List<int> bytes) => _files[path] = bytes;

  List<int>? fileAt(String path) => _files[path];

  bool get isEmpty => _files.isEmpty;

  @override
  Future<PhotoFile?> read(Photo photo) async => switch (_files[photo.path]) {
    null => null,
    final bytes => PhotoFile(bytes: bytes, contentType: 'image/jpeg'),
  };

  @override
  Future<String> save(PhotoId id, PhotoFile file) async {
    final path = '$documentsDir/photos/${id.value}.jpg';
    _files[path] = file.bytes;
    return path;
  }

  @override
  Future<void> delete(Photo photo) async => _files.remove(photo.path);
}
