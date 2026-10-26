import 'dart:async';
import 'dart:developer';

import 'package:flutter/widgets.dart';

import '../application/watch_language_preference.dart';
import '../domain/language_preference.dart';

class AppLanguageViewModel extends ChangeNotifier {
  AppLanguageViewModel(WatchLanguagePreference watchLanguagePreference) {
    _subscription = watchLanguagePreference().listen(
      (preference) {
        _preference = preference;
        _ready = true;
        notifyListeners();
      },
      onError: (Object e, StackTrace stackTrace) {
        log('Reading language failed', error: e, stackTrace: stackTrace);
        _ready = true;
        notifyListeners();
      },
    );
  }

  late final StreamSubscription<LanguagePreference> _subscription;

  LanguagePreference _preference = const LanguagePreference.system();

  bool _ready = false;
  bool get ready => _ready;

  Locale? get locale => switch (_preference.language) {
    null => null,
    final language => Locale(language.code),
  };

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
