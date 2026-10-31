import 'dart:math';

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

  Future<void> deleteFromList(String week) => _tap(
    find.descendant(
      of: find.widgetWithText(ListTile, week),
      matching: find.byTooltip('Delete grocery list'),
    ),
  );

  bool get listHasDeleteButtons =>
      find.byTooltip('Delete grocery list').evaluate().isNotEmpty;

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

  TestGesture? _cardDrag;
  var _dragTime = Duration.zero;

  Future<void> holdCardDragged(double dx) async {
    final gesture = await tester.createGesture();
    _dragTime = Duration.zero;
    await gesture.down(tester.getCenter(_card), timeStamp: _dragTime);
    _cardDrag = gesture;
    await dragCardFurther(dx);
  }

  Future<void> dragCardFurther(double dx) async {
    for (final step in [dx / 2, dx / 2]) {
      _dragTime += const Duration(milliseconds: 100);
      await _cardDrag!.moveBy(Offset(step, 0), timeStamp: _dragTime);
      await tester.pump();
    }
  }

  /// Released after a pause, so the card is let go without any speed.
  Future<void> releaseCard() async {
    _dragTime += const Duration(seconds: 1);
    await _cardDrag!.up(timeStamp: _dragTime);
    _cardDrag = null;
    await tester.pumpAndSettle();
  }

  /// The card's angle on screen in radians, positive when tilted clockwise.
  double get cardTilt {
    final left = tester.getTopLeft(_card);
    final right = tester.getTopRight(_card);
    return atan2(right.dy - left.dy, right.dx - left.dx);
  }

  Finder get _card => find.byType(Card);

  Future<void> _swipe(double dx) async {
    await tester.fling(_card, Offset(dx, 0), 1000);
    await tester.pumpAndSettle();
  }

  Future<void> _tap(Finder finder) async {
    await tester.ensureVisible(finder);
    await tester.tap(finder);
    await tester.pumpAndSettle();
  }
}
