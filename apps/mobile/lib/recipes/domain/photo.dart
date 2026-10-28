import 'photo_id.dart';

class Photo {
  Photo({PhotoId? id, this.path}) : id = id ?? PhotoId.generate() {
    if (path case final path? when path.trim().isEmpty) {
      throw ArgumentError.value(path, 'path', 'must not be blank');
    }
  }

  final PhotoId id;

  final String? path;
}
