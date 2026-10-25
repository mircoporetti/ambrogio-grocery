import 'package:flutter/material.dart';

import '../domain/grocery_list.dart';
import 'week_format.dart';

Future<bool> confirmDeleteGroceryList(
  BuildContext context,
  GroceryList list,
) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text('Delete the list for ${formatWeek(list.week)}?'),
      content: const Text('This cannot be undone.'),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(true),
          child: const Text('Delete'),
        ),
      ],
    ),
  );
  return confirmed == true;
}
