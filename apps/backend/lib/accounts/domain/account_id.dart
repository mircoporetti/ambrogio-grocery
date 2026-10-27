import 'package:uuid/uuid.dart';

class AccountId {
  AccountId(this.value) {
    if (!Uuid.isValidUUID(fromString: value)) {
      throw ArgumentError.value(value, 'value', 'must be a UUID');
    }
  }

  AccountId.generate() : value = const Uuid().v4();

  final String value;

  @override
  bool operator ==(Object other) => other is AccountId && other.value == value;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => 'AccountId($value)';
}
