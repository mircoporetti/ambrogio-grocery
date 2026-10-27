import 'grocery_list.dart';
import 'week.dart';

class GroceryListChange {
  GroceryListChange({
    required this.week,
    required DateTime updatedAt,
    this.list,
  }) : updatedAt = updatedAt.toUtc();

  final Week week;

  final DateTime updatedAt;
  final GroceryList? list;

  bool get deleted => list == null;

  GroceryListChange? applyTo(GroceryListChange? current) {
    if (current == null || updatedAt.isAfter(current.updatedAt)) return this;
    if (updatedAt.isBefore(current.updatedAt)) return null;
    final mine = list;
    final theirs = current.list;
    if (mine == null || theirs == null) {
      return theirs == null ? null : this;
    }
    if (mine.id != theirs.id) {
      // Plannings at the same instant: any rule works if every side uses it.
      return mine.id.value.compareTo(theirs.id.value) > 0 ? this : null;
    }
    final merged = theirs.withTicksFrom(mine);
    if (merged.sameTicksAs(theirs)) return null;
    return GroceryListChange(week: week, updatedAt: updatedAt, list: merged);
  }

  bool sameStateAs(GroceryListChange other) =>
      week == other.week &&
      updatedAt == other.updatedAt &&
      switch ((list, other.list)) {
        (null, null) => true,
        (final mine?, final theirs?) =>
          mine.id == theirs.id && mine.sameTicksAs(theirs),
        _ => false,
      };
}

class GroceryListChangesPage {
  GroceryListChangesPage({
    required this.changes,
    required this.cursor,
    required this.hasMore,
  });

  final List<GroceryListChange> changes;

  final String cursor;
  final bool hasMore;
}
