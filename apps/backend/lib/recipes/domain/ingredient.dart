import 'recipe_exceptions.dart';

enum MeasureUnit {
  grams('g'),
  milliliters('ml');

  const MeasureUnit(this.symbol);

  final String symbol;

  static MeasureUnit? fromSymbol(String symbol) =>
      values.where((u) => u.symbol == symbol).firstOrNull;
}

class Ingredient {
  Ingredient({required this.name, required this.quantity, required this.unit}) {
    if (name.trim().isEmpty) {
      throw const InvalidRecipeException('ingredient name must not be blank');
    }
    if (quantity <= 0) {
      throw const InvalidRecipeException('quantity must be positive');
    }
  }

  final String name;
  final double quantity;
  final MeasureUnit unit;
}
