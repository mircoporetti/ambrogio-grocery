import 'package:flutter/material.dart';

import '../domain/grocery_list.dart';
import '../domain/week.dart';
import 'grocery_list_page.dart';
import 'grocery_list_view_model.dart';
import 'grocery_lists_view_model.dart';
import 'plan_week_page.dart';
import 'plan_week_view_model.dart';
import 'week_format.dart';

class GroceryListsPage extends StatefulWidget {
  const GroceryListsPage({
    super.key,
    required this.viewModel,
    required this.planWeekViewModel,
    required this.groceryListViewModel,
  });

  final GroceryListsViewModel viewModel;
  final PlanWeekViewModel Function() planWeekViewModel;
  final GroceryListViewModel Function(Week week) groceryListViewModel;

  @override
  State<GroceryListsPage> createState() => _GroceryListsPageState();
}

class _GroceryListsPageState extends State<GroceryListsPage> {
  @override
  void dispose() {
    widget.viewModel.dispose();
    super.dispose();
  }

  void _planWeek() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => PlanWeekPage(
          viewModel: widget.planWeekViewModel(),
          groceryListViewModel: widget.groceryListViewModel,
        ),
      ),
    );
  }

  void _openList(GroceryList list) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) =>
            GroceryListPage(viewModel: widget.groceryListViewModel(list.week)),
      ),
    );
  }

  String _subtitle(GroceryList list) {
    final recipes = formatRecipeCount(list.recipes.length);
    return list.week == widget.viewModel.currentWeek
        ? 'This week · $recipes'
        : recipes;
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = widget.viewModel;
    return Scaffold(
      appBar: AppBar(title: const Text('Grocery lists')),
      floatingActionButton: FloatingActionButton(
        tooltip: 'Plan a week',
        onPressed: _planWeek,
        child: const Icon(Icons.add),
      ),
      body: ListenableBuilder(
        listenable: viewModel,
        builder: (context, _) {
          if (viewModel.loading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (viewModel.lists.isEmpty) {
            return const Center(child: Text('No grocery lists yet'));
          }
          return ListView(
            children: [
              for (final list in viewModel.lists)
                ListTile(
                  leading: const Icon(Icons.shopping_cart_outlined),
                  title: Text(formatWeek(list.week)),
                  subtitle: Text(_subtitle(list)),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => _openList(list),
                ),
            ],
          );
        },
      ),
    );
  }
}
