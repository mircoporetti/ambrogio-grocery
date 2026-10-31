import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';

Future<bool> confirmSkipLogIn(BuildContext context) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (context) {
      final l10n = AppLocalizations.of(context);
      return AlertDialog(
        title: Text(l10n.skipLogInTitle),
        content: Text(l10n.skipLogInWarning),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.backToLogIn),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(l10n.continueWithoutAccount),
          ),
        ],
      );
    },
  );
  return confirmed == true;
}
