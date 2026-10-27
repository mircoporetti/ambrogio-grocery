import '../../recipes/domain/ingredient.dart';
import 'grocery_item_id.dart';

class GroceryItem {
  GroceryItem(
    this.ingredient, {
    GroceryItemId? id,
    this.ticked = false,
    DateTime? tickedAt,
  }) : id = id ?? GroceryItemId.generate(),
       tickedAt = tickedAt?.toUtc();

  final GroceryItemId id;
  final Ingredient ingredient;
  final bool ticked;

  final DateTime? tickedAt;

  GroceryItem mergedWith(GroceryItem other) {
    final theirs = other.tickedAt;
    final mine = tickedAt;
    if (theirs == null || (mine != null && !theirs.isAfter(mine))) return this;
    return GroceryItem(
      ingredient,
      id: id,
      ticked: other.ticked,
      tickedAt: theirs,
    );
  }
}
