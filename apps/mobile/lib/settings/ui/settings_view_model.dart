import 'dart:async';

import 'package:flutter/foundation.dart';

import '../application/watch_language_preference.dart';
import '../domain/language_preference.dart';

class SettingsViewModel extends ChangeNotifier {
  SettingsViewModel(WatchLanguagePreference watchLanguagePreference) {
    _subscription = watchLanguagePreference().listen((preference) {
      _language = preference;
      notifyListeners();
    });
  }

  late final StreamSubscription<LanguagePreference> _subscription;

  LanguagePreference? _language;
  LanguagePreference? get language => _language;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
