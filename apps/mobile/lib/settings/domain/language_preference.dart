import 'language.dart';

class LanguagePreference {
  const LanguagePreference.system() : language = null;

  const LanguagePreference.chosen(Language this.language);

  final Language? language;

  @override
  bool operator ==(Object other) =>
      other is LanguagePreference && other.language == language;

  @override
  int get hashCode => language.hashCode;

  @override
  String toString() => 'LanguagePreference(${language?.code ?? 'system'})';
}
