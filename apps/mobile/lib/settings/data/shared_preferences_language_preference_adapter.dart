import 'dart:async';

import 'package:shared_preferences/shared_preferences.dart';

import '../domain/language.dart';
import '../domain/language_preference.dart';
import '../domain/language_preference_port.dart';

class SharedPreferencesLanguagePreferenceAdapter
    implements LanguagePreferencePort {
  SharedPreferencesLanguagePreferenceAdapter(this._preferences);

  static const _key = 'language';

  final SharedPreferencesAsync _preferences;
  final _changes = StreamController<LanguagePreference>.broadcast();

  @override
  Future<void> save(LanguagePreference preference) async {
    final language = preference.language;
    if (language == null) {
      await _preferences.remove(_key);
    } else {
      await _preferences.setString(_key, language.code);
    }
    _changes.add(preference);
  }

  @override
  Stream<LanguagePreference> watch() async* {
    yield await _read();
    yield* _changes.stream;
  }

  Future<LanguagePreference> _read() async {
    final language = Language.fromCode(
      await _preferences.getString(_key) ?? '',
    );
    return language == null
        ? const LanguagePreference.system()
        : LanguagePreference.chosen(language);
  }
}
