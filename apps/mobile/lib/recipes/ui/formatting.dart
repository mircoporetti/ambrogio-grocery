import '../domain/ingredient.dart';

String formatQuantity(Ingredient ingredient) {
  final quantity = ingredient.quantity;
  final number = quantity == quantity.roundToDouble()
      ? quantity.toInt().toString()
      : quantity.toString();
  return '$number ${ingredient.unit.symbol}';
}

String formatPortions(int portions) =>
    portions == 1 ? '1 portion' : '$portions portions';
