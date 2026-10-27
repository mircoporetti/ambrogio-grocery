import 'package:uuid/uuid.dart';

class RecipeId {
  RecipeId(this.value) {
    if (!Uuid.isValidUUID(fromString: value)) {
      throw ArgumentError.value(value, 'value', 'must be a UUID');
    }
  }

  final String value;

  @override
  bool operator ==(Object other) => other is RecipeId && other.value == value;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => 'RecipeId($value)';
}
