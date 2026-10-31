import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

const phoneScreen = Size(390, 844);
const computerScreen = Size(1440, 900);

void useScreen(WidgetTester tester, Size size) {
  tester.view
    ..physicalSize = size
    ..devicePixelRatio = 1;
  addTearDown(tester.view.reset);
}
