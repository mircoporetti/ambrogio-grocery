import 'dart:js_interop';
import 'dart:js_interop_unsafe';

import 'package:web/web.dart' as web;

import '../domain/home_screen_port.dart';

class BrowserHomeScreenAdapter implements HomeScreenPort {
  @override
  Future<bool> canBeAddedToHomeScreen() async => _onIos && !_onHomeScreen;

  bool get _onIos {
    final navigator = web.window.navigator;
    return RegExp('iPhone|iPad|iPod').hasMatch(navigator.userAgent) ||
        (navigator.platform == 'MacIntel' && navigator.maxTouchPoints > 1);
  }

  bool get _onHomeScreen =>
      web.window.matchMedia('(display-mode: standalone)').matches ||
      (web.window.navigator as JSObject)
              .getProperty<JSAny?>('standalone'.toJS)
              .dartify() ==
          true;
}
