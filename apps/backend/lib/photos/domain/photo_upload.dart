import 'photo_exceptions.dart';

class PhotoUpload {
  PhotoUpload({required String contentType, required this.size})
    : contentType = contentType.trim().toLowerCase() {
    if (size < 1) throw ArgumentError.value(size, 'size', 'must be positive');
    if (size > maxSize) throw const PhotoTooLargeException();
    if (!contentTypes.contains(this.contentType)) {
      throw const UnsupportedPhotoTypeException();
    }
  }

  static const maxSize = 10 * 1024 * 1024;

  static const contentTypes = {
    'image/jpeg',
    'image/png',
    'image/heic',
    'image/webp',
  };

  final String contentType;
  final int size;
}
