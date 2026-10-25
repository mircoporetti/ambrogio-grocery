import 'package:flutter/material.dart';

import '../../recipes/ui/formatting.dart';
import '../domain/grocery_item.dart';
import '../domain/grocery_list.dart';
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

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.viewModel,
      builder: (context, _) => Scaffold(
        appBar: AppBar(
          title: const Text('Grocery list'),
          bottom: _errorBanner(context),
        ),
        body: switch ((widget.viewModel.loading, widget.viewModel.list)) {
          (true, _) => const Center(child: CircularProgressIndicator()),
          (false, null) => const Center(
            child: Text('This grocery list no longer exists'),
          ),
          (false, final GroceryList list) => _GroceryListItems(
            list: list,
            items: widget.viewModel.items,
            onToggle: widget.viewModel.toggle,
          ),
        },
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
          child: Text(error, style: TextStyle(color: colors.onErrorContainer)),
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
  final List<(int, GroceryItem)> items;
  final void Function(int index) onToggle;

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
              Text(formatWeek(list.week), style: textTheme.titleLarge),
              const SizedBox(height: 4),
              Text(list.recipes.join(', '), style: textTheme.bodyMedium),
            ],
          ),
        ),
        for (final (index, item) in items)
          _GroceryItemTile(item: item, onToggle: () => onToggle(index)),
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
        trailing: Text(formatQuantity(ingredient), style: style),
        onTap: onToggle,
      ),
    );
  }
}
