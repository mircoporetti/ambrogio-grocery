import 'package:uuid/uuid.dart';

class GroceryItemId {
  GroceryItemId(this.value) {
    if (value.trim().isEmpty) {
      throw ArgumentError.value(value, 'value', 'must not be blank');
    }
  }

  GroceryItemId.generate() : value = const Uuid().v4();

  final String value;

  @override
  bool operator ==(Object other) =>
      other is GroceryItemId && other.value == value;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => 'GroceryItemId($value)';
}
