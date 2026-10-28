sealed class PhotoException implements Exception {
  const PhotoException();
}

class PhotoNotFoundException extends PhotoException {
  const PhotoNotFoundException();
}

class PhotoTooLargeException extends PhotoException {
  const PhotoTooLargeException();
}

class UnsupportedPhotoTypeException extends PhotoException {
  const UnsupportedPhotoTypeException();
}
