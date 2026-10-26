import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class LanguageRobot {
  LanguageRobot(this.tester);

  final WidgetTester tester;

  void setPhoneLanguage(Locale locale) {
    tester.platformDispatcher.localesTestValue = [locale];
    addTearDown(tester.platformDispatcher.clearLocalesTestValue);
  }

  Future<void> tapText(String text) => _tap(find.text(text));

  Future<void> tapButton(String tooltip) => _tap(find.byTooltip(tooltip));

  Future<void> enter(String label, String text) async {
    final field = find.widgetWithText(TextFormField, label);
    await tester.ensureVisible(field);
    await tester.enterText(field, text);
    await tester.pumpAndSettle();
  }

  Future<void> _tap(Finder finder) async {
    await tester.ensureVisible(finder);
    await tester.tap(finder);
    await tester.pumpAndSettle();
  }
}
