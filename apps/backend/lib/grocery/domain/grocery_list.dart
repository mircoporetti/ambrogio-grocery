import 'package:uuid/uuid.dart';

import 'grocery_exceptions.dart';
import 'grocery_item.dart';

class GroceryList {
  GroceryList({
    required this.id,
    required List<String> recipes,
    required List<GroceryItem> items,
  }) : recipes = List.unmodifiable(recipes),
       items = List.unmodifiable(items) {
    if (!Uuid.isValidUUID(fromString: id)) {
      throw ArgumentError.value(id, 'id', 'must be a UUID');
    }
    if (recipes.isEmpty) {
      throw const InvalidGroceryListException('recipes must not be empty');
    }
    if (items.isEmpty) {
      throw const InvalidGroceryListException('items must not be empty');
    }
    if (items.map((i) => i.id).toSet().length != items.length) {
      throw const InvalidGroceryListException('item ids must be unique');
    }
  }

  final String id;
  final List<String> recipes;
  final List<GroceryItem> items;

  GroceryList withTicksFrom(GroceryList other) {
    final theirs = {for (final item in other.items) item.id: item};
    return GroceryList(
      id: id,
      recipes: recipes,
      items: [
        for (final item in items)
          switch (theirs[item.id]) {
            null => item,
            final their => item.mergedWith(their),
          },
      ],
    );
  }

  bool sameTicksAs(GroceryList other) {
    final theirs = {for (final item in other.items) item.id: item};
    return items.every(
      (item) =>
          theirs[item.id]?.ticked == item.ticked &&
          theirs[item.id]?.tickedAt == item.tickedAt,
    );
  }
}
