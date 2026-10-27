import 'package:uuid/uuid.dart';

class PhotoId {
  PhotoId(this.value) {
    if (value.trim().isEmpty) {
      throw ArgumentError.value(value, 'value', 'must not be blank');
    }
  }

  PhotoId.generate() : value = const Uuid().v4();

  final String value;

  @override
  bool operator ==(Object other) => other is PhotoId && other.value == value;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => 'PhotoId($value)';
}
