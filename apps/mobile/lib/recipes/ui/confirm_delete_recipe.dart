import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../domain/recipe.dart';

Future<bool> confirmDeleteRecipe(BuildContext context, Recipe recipe) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (context) {
      final l10n = AppLocalizations.of(context);
      return AlertDialog(
        title: Text(l10n.confirmDeleteRecipe(recipe.title)),
        content: Text(l10n.cannotBeUndone),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(l10n.delete),
          ),
        ],
      );
    },
  );
  return confirmed == true;
}
