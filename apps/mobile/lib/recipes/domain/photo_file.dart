class PhotoFile {
  PhotoFile({required List<int> bytes, required this.contentType})
    : bytes = List.unmodifiable(bytes) {
    if (bytes.isEmpty) {
      throw ArgumentError.value(bytes, 'bytes', 'must not be empty');
    }
  }

  final List<int> bytes;
  final String contentType;
}
