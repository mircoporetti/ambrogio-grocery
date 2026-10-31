import 'package:flutter/material.dart';

import '../../shared/ui/readable_width.dart';

import '../../l10n/app_localizations.dart';
import '../../recipes/ui/formatting.dart';
import '../domain/grocery_item.dart';
import '../domain/grocery_item_id.dart';
import '../domain/grocery_list.dart';
import 'confirm_delete_grocery_list.dart';
import 'grocery_list_view_model.dart';
import 'week_format.dart';

class GroceryListPage extends StatefulWidget {
  const GroceryListPage({super.key, required this.viewModel});

  final GroceryListViewModel viewModel;

  @override
  State<GroceryListPage> createState() => _GroceryListPageState();
}

class _GroceryListPageState extends State<GroceryListPage> {
  @override
  void dispose() {
    widget.viewModel.dispose();
    super.dispose();
  }

  Future<void> _confirmAndDelete(GroceryList list) async {
    if (!await confirmDeleteGroceryList(context, list)) return;
    final deleted = await widget.viewModel.delete();
    if (deleted && mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.viewModel,
      builder: (context, _) => Scaffold(
        appBar: AppBar(
          title: Text(AppLocalizations.of(context).groceryList),
          actions: [
            if (widget.viewModel.list case final GroceryList list)
              IconButton(
                tooltip: AppLocalizations.of(context).deleteGroceryList,
                icon: const Icon(Icons.delete_outline),
                onPressed: widget.viewModel.deleting
                    ? null
                    : () => _confirmAndDelete(list),
              ),
          ],
          bottom: _errorBanner(context),
        ),
        body: ReadableWidth(
          maxWidth: ReadableWidth.list,
          child: switch ((widget.viewModel.loading, widget.viewModel.list)) {
            (true, _) => const Center(child: CircularProgressIndicator()),
            (false, null) => Center(
              child: Text(
                AppLocalizations.of(context).groceryListNoLongerExists,
              ),
            ),
            (false, final GroceryList list) => _GroceryListItems(
              list: list,
              items: widget.viewModel.items,
              onToggle: widget.viewModel.toggle,
            ),
          },
        ),
      ),
    );
  }

  PreferredSizeWidget? _errorBanner(BuildContext context) {
    final error = widget.viewModel.error;
    if (error == null) return null;
    final colors = Theme.of(context).colorScheme;
    return PreferredSize(
      preferredSize: const Size.fromHeight(44),
      child: Container(
        width: double.infinity,
        color: colors.errorContainer,
        padding: const EdgeInsets.all(12),
        child: Semantics(
          liveRegion: true,
          child: Text(
            error.message(AppLocalizations.of(context)),
            style: TextStyle(color: colors.onErrorContainer),
          ),
        ),
      ),
    );
  }
}

class _GroceryListItems extends StatelessWidget {
  const _GroceryListItems({
    required this.list,
    required this.items,
    required this.onToggle,
  });

  final GroceryList list;
  final List<GroceryItem> items;
  final void Function(GroceryItemId item) onToggle;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return ListView(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                formatWeek(AppLocalizations.of(context), list.week),
                style: textTheme.titleLarge,
              ),
              const SizedBox(height: 4),
              Text(list.recipes.join(', '), style: textTheme.bodyMedium),
            ],
          ),
        ),
        for (final item in items)
          _GroceryItemTile(item: item, onToggle: () => onToggle(item.id)),
      ],
    );
  }
}

class _GroceryItemTile extends StatelessWidget {
  const _GroceryItemTile({required this.item, required this.onToggle});

  final GroceryItem item;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    final ingredient = item.ingredient;
    final style = item.ticked
        ? TextStyle(
            decoration: TextDecoration.lineThrough,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          )
        : null;
    return MergeSemantics(
      child: ListTile(
        leading: Checkbox(value: item.ticked, onChanged: (_) => onToggle()),
        title: Text(ingredient.name, style: style),
        trailing: Text(
          formatQuantity(AppLocalizations.of(context), ingredient),
          style: style,
        ),
        onTap: onToggle,
      ),
    );
  }
}
