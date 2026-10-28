import 'photo_file.dart';
import 'photo_id.dart';

abstract interface class PhotoSyncApiPort {
  Future<void> upload(String accessToken, PhotoId id, PhotoFile file);

  Future<PhotoFile?> download(String accessToken, PhotoId id);
}
