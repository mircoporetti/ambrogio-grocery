import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class GroceryRobot {
  GroceryRobot(this.tester);

  final WidgetTester tester;

  Future<void> openGroceryLists() => _tap(find.byTooltip('Grocery lists'));

  Future<void> planWeek() => _tap(find.byTooltip('Plan a week'));

  Future<void> startPlanningWeek() async {
    await openGroceryLists();
    await planWeek();
  }

  Future<void> openGroceryList(String week) => _tap(find.text(week));

  Future<void> laterWeek() => _tap(find.byTooltip('Later week'));

  Future<void> earlierWeek() => _tap(find.byTooltip('Earlier week'));

  bool get canChooseEarlierWeek =>
      tester
          .widget<IconButton>(
            find.ancestor(
              of: find.byTooltip('Earlier week'),
              matching: find.byType(IconButton),
            ),
          )
          .onPressed !=
      null;

  Future<void> tick(String item) => _tap(find.text(item));

  Future<void> untick(String item) => _tap(find.text(item));

  bool isTicked(String item) =>
      tester
          .widget<Checkbox>(
            find.descendant(
              of: find.ancestor(
                of: find.text(item),
                matching: find.byType(ListTile),
              ),
              matching: find.byType(Checkbox),
            ),
          )
          .value ==
      true;

  Future<void> deleteOpenGroceryList() =>
      _tap(find.byTooltip('Delete grocery list'));

  Future<void> swipeToDelete(String week) async {
    await tester.fling(
      find.ancestor(of: find.text(week), matching: find.byType(Dismissible)),
      const Offset(-500, 0),
      1000,
    );
    await tester.pumpAndSettle();
  }

  Future<void> confirmDelete() => _tap(find.text('Delete'));

  Future<void> cancelDelete() => _tap(find.text('Cancel'));

  Future<void> confirmReplace() => _tap(find.text('Replace'));

  Future<void> cancelReplace() => _tap(find.text('Cancel'));

  Future<void> cook() => _tap(find.text('Cook'));

  Future<void> skip() => _tap(find.text('Skip'));

  Future<void> swipeToCook() => _swipe(500);

  Future<void> swipeToSkip() => _swipe(-500);

  Future<void> createGroceryList() => _tap(_createListButton);

  Future<void> goBack() => _tap(find.byTooltip('Back'));

  bool get canCreateGroceryList =>
      tester.widget<ButtonStyleButton>(_createListButton).onPressed != null;

  List<String> get groceryList => [
    for (final tile in tester.widgetList<ListTile>(find.byType(ListTile)))
      '${(tile.title! as Text).data} ${(tile.trailing! as Text).data}',
  ];

  List<String> get groceryListWeeks => [
    for (final tile in tester.widgetList<ListTile>(find.byType(ListTile)))
      (tile.title! as Text).data!,
  ];

  Finder get _createListButton => find.ancestor(
    of: find.text('Create grocery list'),
    matching: find.byWidgetPredicate((w) => w is ButtonStyleButton),
  );

  Future<void> _swipe(double dx) async {
    await tester.fling(find.byType(Dismissible), Offset(dx, 0), 1000);
    await tester.pumpAndSettle();
  }

  Future<void> _tap(Finder finder) async {
    await tester.ensureVisible(finder);
    await tester.tap(finder);
    await tester.pumpAndSettle();
  }
}
