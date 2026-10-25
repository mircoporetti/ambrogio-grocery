import 'package:flutter/material.dart';

import '../../recipes/ui/formatting.dart';
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
    return Scaffold(
      appBar: AppBar(title: const Text('Grocery list')),
      body: ListenableBuilder(
        listenable: widget.viewModel,
        builder: (context, _) =>
            switch ((widget.viewModel.loading, widget.viewModel.list)) {
              (true, _) => const Center(child: CircularProgressIndicator()),
              (false, null) => const Center(
                child: Text('This grocery list no longer exists'),
              ),
              (false, final GroceryList list) => _GroceryListItems(list: list),
            },
      ),
    );
  }
}

class _GroceryListItems extends StatelessWidget {
  const _GroceryListItems({required this.list});

  final GroceryList list;

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
        for (final item in list.items)
          ListTile(
            title: Text(item.name),
            trailing: Text(formatQuantity(item)),
          ),
      ],
    );
  }
}
