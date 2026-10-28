import 'photo.dart';
import 'photo_file.dart';
import 'photo_id.dart';

abstract interface class PhotoStoragePort {
  Future<PhotoFile?> read(Photo photo);

  Future<String> save(PhotoId id, PhotoFile file);

  Future<void> delete(Photo photo);
}
