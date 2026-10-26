import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class SettingsRobot {
  SettingsRobot(this.tester);

  final WidgetTester tester;

  Future<void> openSettings({String tooltip = 'Settings'}) =>
      _tap(find.byTooltip(tooltip));

  Future<void> openLanguage({String label = 'Language'}) =>
      _tap(find.text(label));

  Future<void> chooseLanguage(String name) => _tap(find.text(name));

  Future<void> goBack() => _tap(find.byType(BackButton));

  String languageSetting({String label = 'Language'}) => _text(
    tester
        .widget<ListTile>(
          find.ancestor(of: find.text(label), matching: find.byType(ListTile)),
        )
        .subtitle!,
  );

  List<String> get languages => [
    for (final tile in _languageTiles) _text(tile.title!),
  ];

  String get tickedLanguage =>
      _text(_languageTiles.where((tile) => tile.selected).single.title!);

  Iterable<ListTile> get _languageTiles =>
      tester.widgetList<ListTile>(find.byType(ListTile));

  String _text(Widget widget) => (widget as Text).data!;

  Future<void> _tap(Finder finder) async {
    await tester.ensureVisible(finder);
    await tester.tap(finder);
    await tester.pumpAndSettle();
  }
}
