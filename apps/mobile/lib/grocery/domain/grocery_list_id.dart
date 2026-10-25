import 'package:uuid/uuid.dart';

class GroceryListId {
  GroceryListId(this.value) {
    if (value.trim().isEmpty) {
      throw ArgumentError.value(value, 'value', 'must not be blank');
    }
  }

  GroceryListId.generate() : value = const Uuid().v4();

  final String value;

  @override
  bool operator ==(Object other) =>
      other is GroceryListId && other.value == value;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => 'GroceryListId($value)';
}
