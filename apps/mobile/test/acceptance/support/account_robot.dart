import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class AccountRobot {
  AccountRobot(this.tester);

  final WidgetTester tester;

  Future<void> openSettings() => _tap(find.byTooltip('Settings'));

  String get accountSetting => _text(
    tester
        .widget<ListTile>(
          find.ancestor(
            of: find.text('Account'),
            matching: find.byType(ListTile),
          ),
        )
        .subtitle!,
  );

  Future<void> openLogIn() => _tap(find.text('Account'));

  Future<void> switchToCreateAccount() => _tap(find.text('Create an account'));

  Future<void> switchToLogIn() => _tap(find.text('I already have an account'));

  Future<void> enterEmail(String email) => _enter('Email', email);

  Future<void> enterPassword(String password) => _enter('Password', password);

  Future<void> submit() => _tap(find.byType(FilledButton));

  Future<void> logIn(String email, String password) async {
    await openSettings();
    await openLogIn();
    await enterEmail(email);
    await enterPassword(password);
    await submit();
  }

  Future<void> createAccount(String email, String password) async {
    await openSettings();
    await openLogIn();
    await switchToCreateAccount();
    await enterEmail(email);
    await enterPassword(password);
    await submit();
  }

  Future<void> logOut() => _tap(find.text('Log out'));

  bool get isAskedToLogIn =>
      find.text('You can log in later in Settings.').evaluate().isNotEmpty;

  Future<void> skipLogIn() => _tap(find.text('Skip'));

  Future<void> goBackWithSystemButton() async {
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
  }

  String? get pageTitle => tester
      .widgetList<AppBar>(find.byType(AppBar))
      .map((bar) => (bar.title as Text?)?.data)
      .last;

  String fieldText(String label) => tester
      .widget<TextField>(find.widgetWithText(TextField, label))
      .controller!
      .text;

  Future<void> _enter(String label, String text) async {
    final field = find.widgetWithText(TextFormField, label);
    await tester.ensureVisible(field);
    await tester.enterText(field, text);
    await tester.pumpAndSettle();
  }

  String _text(Widget widget) => (widget as Text).data!;

  Future<void> _tap(Finder finder) async {
    await tester.ensureVisible(finder);
    await tester.tap(finder);
    await tester.pumpAndSettle();
  }
}
