import 'dart:async';

import '../../grocery/application/watch_pending_grocery_list_changes.dart';
import '../../recipes/application/watch_pending_recipe_changes.dart';

class WatchPendingChanges {
  WatchPendingChanges(this._recipes, this._groceryLists);

  final WatchPendingRecipeChanges _recipes;
  final WatchPendingGroceryListChanges _groceryLists;

  Stream<int> call() {
    final sources = [_recipes(), _groceryLists()];
    final counts = List<int?>.filled(sources.length, null);
    final subscriptions = <StreamSubscription<int>>[];
    late final StreamController<int> controller;
    controller = StreamController<int>(
      onListen: () {
        for (final (index, source) in sources.indexed) {
          subscriptions.add(
            source.listen((count) {
              counts[index] = count;
              if (counts.every((c) => c != null)) {
                controller.add(counts.fold(0, (sum, c) => sum + c!));
              }
            }, onError: controller.addError),
          );
        }
      },
      onCancel: () async {
        for (final subscription in subscriptions) {
          await subscription.cancel();
        }
      },
    );
    return controller.stream;
  }
}
