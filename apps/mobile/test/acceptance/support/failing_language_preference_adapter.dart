import 'package:ambrogio_grocery/settings/domain/language_preference.dart';
import 'package:ambrogio_grocery/settings/domain/language_preference_port.dart';

class FailingLanguagePreferenceAdapter implements LanguagePreferencePort {
  FailingLanguagePreferenceAdapter(this._real);

  final LanguagePreferencePort _real;

  bool failSaves = false;

  @override
  Future<void> save(LanguagePreference preference) async {
    if (failSaves) throw Exception('Simulated storage failure');
    await _real.save(preference);
  }

  @override
  Stream<LanguagePreference> watch() => _real.watch();
}
