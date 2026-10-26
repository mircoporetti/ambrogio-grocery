import 'package:intl/intl.dart';

import '../../l10n/app_localizations.dart';
import '../domain/week.dart';

String formatWeek(AppLocalizations l10n, Week week) {
  final locale = l10n.localeName;
  final start = week.start;
  final end = week.end;
  final day = DateFormat.d(locale);
  final dayMonth = DateFormat('d MMM', locale);
  final dayMonthYear = DateFormat('d MMM y', locale);
  if (start.year != end.year) {
    return '${dayMonthYear.format(start)} – ${dayMonthYear.format(end)}';
  }
  if (start.month != end.month) {
    return '${dayMonth.format(start)} – ${dayMonth.format(end)}';
  }
  return '${day.format(start)} – ${dayMonth.format(end)}';
}
