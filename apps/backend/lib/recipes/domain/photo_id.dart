import 'package:uuid/uuid.dart';

class PhotoId {
  PhotoId(this.value) {
    if (!Uuid.isValidUUID(fromString: value)) {
      throw ArgumentError.value(value, 'value', 'must be a UUID');
    }
  }

  final String value;

  @override
  bool operator ==(Object other) => other is PhotoId && other.value == value;

  @override
  int get hashCode => value.hashCode;
}
