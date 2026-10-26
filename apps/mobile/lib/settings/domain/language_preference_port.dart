import 'language_preference.dart';

abstract interface class LanguagePreferencePort {
  Future<void> save(LanguagePreference preference);

  Stream<LanguagePreference> watch();
}
