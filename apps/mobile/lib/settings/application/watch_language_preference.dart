import '../domain/language_preference.dart';
import '../domain/language_preference_port.dart';

class WatchLanguagePreference {
  WatchLanguagePreference(this._storage);

  final LanguagePreferencePort _storage;

  Stream<LanguagePreference> call() => _storage.watch();
}
