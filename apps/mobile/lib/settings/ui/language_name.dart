import '../../l10n/app_localizations.dart';
import '../domain/language.dart';
import '../domain/language_preference.dart';

String languageName(AppLocalizations l10n, LanguagePreference preference) =>
    switch (preference.language) {
      null => l10n.systemDefault,
      Language.english => 'English',
      Language.italian => 'Italiano',
    };
