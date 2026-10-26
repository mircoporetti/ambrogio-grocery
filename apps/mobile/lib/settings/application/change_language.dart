import '../domain/language_preference.dart';
import '../domain/language_preference_port.dart';

class ChangeLanguage {
  ChangeLanguage(this._storage);

  final LanguagePreferencePort _storage;

  Future<void> call(LanguagePreference preference) => _storage.save(preference);
}
