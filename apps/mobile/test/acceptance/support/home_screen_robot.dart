import 'package:flutter_test/flutter_test.dart';

class HomeScreenRobot {
  HomeScreenRobot(this.tester);

  final WidgetTester tester;

  bool get isAskedToAddToHomeScreen =>
      find.textContaining('add it to your Home Screen').evaluate().isNotEmpty;

  Future<void> notNow() async {
    await tester.tap(find.text('Not now'));
    await tester.pumpAndSettle();
  }
}
