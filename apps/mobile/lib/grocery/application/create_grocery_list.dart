import '../../recipes/domain/recipe.dart';
import '../domain/clock_port.dart';
import '../domain/grocery_list.dart';
import '../domain/grocery_list_storage_port.dart';
import '../domain/past_week_exception.dart';
import '../domain/week.dart';

class CreateGroceryList {
  CreateGroceryList(this._storage, this._clock);

  final GroceryListStoragePort _storage;
  final ClockPort _clock;

  Future<void> call(Week week, List<Recipe> recipes) async {
    if (week.isBefore(Week.containing(_clock.now()))) {
      throw PastWeekException(week);
    }
    await _storage.save(GroceryList.plan(week, recipes));
  }
}
