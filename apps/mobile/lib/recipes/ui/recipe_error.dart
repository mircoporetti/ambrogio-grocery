import '../../l10n/app_localizations.dart';

enum RecipeError {
  saveFailed,
  deleteFailed;

  String message(AppLocalizations l10n) => switch (this) {
    saveFailed => l10n.saveRecipeFailed,
    deleteFailed => l10n.deleteRecipeFailed,
  };
}
