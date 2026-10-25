import '../../recipes/domain/recipe.dart';
import '../domain/grocery_list.dart';
import '../domain/grocery_list_storage_port.dart';
import '../domain/week.dart';

class CreateGroceryList {
  CreateGroceryList(this._storage);

  final GroceryListStoragePort _storage;

  Future<void> call(Week week, List<Recipe> recipes) =>
      _storage.save(GroceryList.plan(week, recipes));
}
