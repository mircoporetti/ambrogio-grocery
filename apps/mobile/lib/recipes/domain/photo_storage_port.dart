import 'photo.dart';

abstract interface class PhotoStoragePort {
  Future<void> delete(Photo photo);
}
