import 'package:uuid/uuid.dart';

import 'grocery_exceptions.dart';

enum MeasureUnit {
  grams('g'),
  milliliters('ml');

  const MeasureUnit(this.symbol);

  final String symbol;

  static MeasureUnit? fromSymbol(String symbol) =>
      values.where((u) => u.symbol == symbol).firstOrNull;
}

class GroceryItem {
  GroceryItem({
    required this.id,
    required this.name,
    required this.quantity,
    required this.unit,
    this.ticked = false,
    DateTime? tickedAt,
  }) : tickedAt = tickedAt?.toUtc() {
    if (!Uuid.isValidUUID(fromString: id)) {
      throw ArgumentError.value(id, 'id', 'must be a UUID');
    }
    if (name.trim().isEmpty) {
      throw const InvalidGroceryListException('item name must not be blank');
    }
    if (quantity <= 0) {
      throw const InvalidGroceryListException('quantity must be positive');
    }
  }

  final String id;
  final String name;
  final double quantity;
  final MeasureUnit unit;
  final bool ticked;

  final DateTime? tickedAt;

  GroceryItem mergedWith(GroceryItem other) {
    final theirs = other.tickedAt;
    final mine = tickedAt;
    if (theirs == null || (mine != null && !theirs.isAfter(mine))) return this;
    return GroceryItem(
      id: id,
      name: name,
      quantity: quantity,
      unit: unit,
      ticked: other.ticked,
      tickedAt: theirs,
    );
  }
}
