import 'package:uuid/uuid.dart';

class RecipeId {
  RecipeId(this.value) {
    if (value.trim().isEmpty) {
      throw ArgumentError.value(value, 'value', 'must not be blank');
    }
  }

  RecipeId.generate() : value = const Uuid().v4();

  final String value;

  @override
  bool operator ==(Object other) => other is RecipeId && other.value == value;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => 'RecipeId($value)';
}
