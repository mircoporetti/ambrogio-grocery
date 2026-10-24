enum MeasureUnit {
  grams('g'),
  milliliters('ml');

  const MeasureUnit(this.symbol);

  final String symbol;
}

class Ingredient {
  Ingredient({required this.name, required this.quantity, required this.unit}) {
    if (name.trim().isEmpty) {
      throw ArgumentError.value(name, 'name', 'must not be blank');
    }
    if (quantity <= 0) {
      throw ArgumentError.value(quantity, 'quantity', 'must be positive');
    }
  }

  final String name;
  final double quantity;
  final MeasureUnit unit;

  @override
  bool operator ==(Object other) =>
      other is Ingredient &&
      other.name == name &&
      other.quantity == quantity &&
      other.unit == unit;

  @override
  int get hashCode => Object.hash(name, quantity, unit);

  @override
  String toString() => 'Ingredient($name, $quantity ${unit.symbol})';
}
