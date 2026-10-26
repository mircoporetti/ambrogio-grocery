import 'dart:async';
import 'dart:developer';

import 'package:flutter/foundation.dart';

import '../application/change_language.dart';
import '../application/watch_language_preference.dart';
import '../domain/language.dart';
import '../domain/language_preference.dart';

class LanguageViewModel extends ChangeNotifier {
  LanguageViewModel(
    WatchLanguagePreference watchLanguagePreference,
    this._changeLanguage,
  ) {
    _subscription = watchLanguagePreference().listen((preference) {
      _current = preference;
      notifyListeners();
    });
  }

  final ChangeLanguage _changeLanguage;
  late final StreamSubscription<LanguagePreference> _subscription;

  final List<LanguagePreference> choices = [
    const LanguagePreference.system(),
    for (final language in Language.values) LanguagePreference.chosen(language),
  ];

  LanguagePreference? _current;
  LanguagePreference? get current => _current;

  bool _saving = false;
  bool get saving => _saving;

  bool _failed = false;

  bool get failed => _failed;

  Future<bool> choose(LanguagePreference preference) async {
    _saving = true;
    _failed = false;
    notifyListeners();
    try {
      await _changeLanguage(preference);
      return true;
    } on Exception catch (e, stackTrace) {
      log('Changing language failed', error: e, stackTrace: stackTrace);
      _failed = true;
      return false;
    } finally {
      _saving = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
