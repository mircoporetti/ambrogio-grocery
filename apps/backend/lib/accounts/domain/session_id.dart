import 'package:uuid/uuid.dart';

class SessionId {
  SessionId(this.value) {
    if (!Uuid.isValidUUID(fromString: value)) {
      throw ArgumentError.value(value, 'value', 'must be a UUID');
    }
  }

  SessionId.generate() : value = const Uuid().v4();

  final String value;

  @override
  bool operator ==(Object other) => other is SessionId && other.value == value;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => 'SessionId($value)';
}
