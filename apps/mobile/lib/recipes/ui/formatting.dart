import 'package:intl/intl.dart';

import '../../l10n/app_localizations.dart';
import '../domain/ingredient.dart';

String formatQuantity(AppLocalizations l10n, Ingredient ingredient) {
  final number = NumberFormat('0.###', l10n.localeName);
  return '${number.format(ingredient.quantity)} ${ingredient.unit.symbol}';
}
