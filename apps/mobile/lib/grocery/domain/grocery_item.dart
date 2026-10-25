import '../../recipes/domain/ingredient.dart';

class GroceryItem {
  GroceryItem(this.ingredient, {this.ticked = false});

  final Ingredient ingredient;
  final bool ticked;
}
