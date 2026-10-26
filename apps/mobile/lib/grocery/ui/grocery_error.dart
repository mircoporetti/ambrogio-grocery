import '../../l10n/app_localizations.dart';
import '../domain/week.dart';
import 'week_format.dart';

sealed class GroceryError {
  const GroceryError();

  String message(AppLocalizations l10n) => switch (this) {
    SaveFailed() => l10n.saveGroceryListFailed,
    UpdateFailed() => l10n.updateGroceryListFailed,
    DeleteFailed() => l10n.deleteGroceryListFailed,
    WeekIsOver(:final week) => l10n.weekIsOver(formatWeek(l10n, week)),
  };
}

class SaveFailed extends GroceryError {
  const SaveFailed();
}

class UpdateFailed extends GroceryError {
  const UpdateFailed();
}

class DeleteFailed extends GroceryError {
  const DeleteFailed();
}

class WeekIsOver extends GroceryError {
  const WeekIsOver(this.week);

  final Week week;
}
