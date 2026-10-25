import '../domain/clock_port.dart';
import '../domain/grocery_list.dart';
import '../domain/grocery_list_storage_port.dart';
import '../domain/week.dart';

class WatchUpcomingGroceryLists {
  WatchUpcomingGroceryLists(this._storage, this._clock);

  final GroceryListStoragePort _storage;
  final ClockPort _clock;

  Stream<List<GroceryList>> call() =>
      _storage.watchFrom(Week.containing(_clock.now()));
}
