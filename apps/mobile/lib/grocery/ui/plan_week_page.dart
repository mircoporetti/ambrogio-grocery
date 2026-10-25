import 'dart:io';

import 'package:flutter/material.dart';

import '../../recipes/domain/recipe.dart';
import '../../recipes/ui/formatting.dart';
import '../domain/week.dart';
import 'grocery_list_page.dart';
import 'grocery_list_view_model.dart';
import 'plan_week_view_model.dart';
import 'week_format.dart';

class PlanWeekPage extends StatefulWidget {
  const PlanWeekPage({
    super.key,
    required this.viewModel,
    required this.groceryListViewModel,
  });

  final PlanWeekViewModel viewModel;
  final GroceryListViewModel Function(Week week) groceryListViewModel;

  @override
  State<PlanWeekPage> createState() => _PlanWeekPageState();
}

class _PlanWeekPageState extends State<PlanWeekPage> {
  @override
  void dispose() {
    widget.viewModel.dispose();
    super.dispose();
  }

  Future<bool> _confirmReplace() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Replace the list for ${formatWeek(widget.viewModel.week)}?',
        ),
        content: const Text('The current list of that week will be lost.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Replace'),
          ),
        ],
      ),
    );
    return confirmed == true;
  }

  Future<void> _createGroceryList() async {
    final viewModel = widget.viewModel;
    if (await viewModel.replacesList()) {
      if (!mounted || !await _confirmReplace()) return;
    }
    final week = viewModel.week;
    if (!await viewModel.createGroceryList() || !mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(
        builder: (_) =>
            GroceryListPage(viewModel: widget.groceryListViewModel(week)),
      ),
    );
  }

  String _chosenSummary(int count) => switch (count) {
    0 => 'No recipes chosen yet',
    1 => '1 recipe chosen',
    _ => '$count recipes chosen',
  };

  @override
  Widget build(BuildContext context) {
    final viewModel = widget.viewModel;
    return Scaffold(
      appBar: AppBar(title: const Text('Plan the week')),
      body: ListenableBuilder(
        listenable: viewModel,
        builder: (context, _) => Column(
          children: [
            _WeekPicker(viewModel: viewModel),
            Expanded(child: _deck(viewModel)),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: ListenableBuilder(
            listenable: viewModel,
            builder: (context, _) {
              final error = viewModel.error;
              final colors = Theme.of(context).colorScheme;
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (error != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Semantics(
                        liveRegion: true,
                        child: Text(
                          error,
                          style: TextStyle(color: colors.error),
                        ),
                      ),
                    ),
                  Semantics(
                    liveRegion: true,
                    child: Text(_chosenSummary(viewModel.chosenCount)),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: viewModel.canCreateGroceryList
                          ? _createGroceryList
                          : null,
                      child: const Text('Create grocery list'),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _deck(PlanWeekViewModel viewModel) {
    if (viewModel.loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (viewModel.recipes.isEmpty) {
      return const Center(child: Text('Add some recipes to plan your week'));
    }
    final recipe = viewModel.current;
    if (recipe == null) {
      return const Center(child: Text("You've seen all your recipes"));
    }
    return _RecipeDeck(
      recipe: recipe,
      position: '${viewModel.position} of ${viewModel.recipes.length}',
      onCook: viewModel.cook,
      onSkip: viewModel.skip,
    );
  }
}

class _WeekPicker extends StatelessWidget {
  const _WeekPicker({required this.viewModel});

  final PlanWeekViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        children: [
          IconButton(
            tooltip: 'Earlier week',
            icon: const Icon(Icons.chevron_left),
            onPressed: viewModel.canChooseEarlierWeek
                ? viewModel.earlierWeek
                : null,
          ),
          Expanded(
            child: Text(
              formatWeek(viewModel.week),
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          IconButton(
            tooltip: 'Later week',
            icon: const Icon(Icons.chevron_right),
            onPressed: viewModel.laterWeek,
          ),
        ],
      ),
    );
  }
}

class _RecipeDeck extends StatelessWidget {
  const _RecipeDeck({
    required this.recipe,
    required this.position,
    required this.onCook,
    required this.onSkip,
  });

  final Recipe recipe;
  final String position;
  final VoidCallback onCook;
  final VoidCallback onSkip;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Text(position),
          const SizedBox(height: 8),
          Expanded(
            child: Dismissible(
              key: ValueKey(recipe.id),
              onDismissed: (direction) =>
                  direction == DismissDirection.startToEnd
                  ? onCook()
                  : onSkip(),
              background: _SwipeHint(
                label: 'Cook',
                icon: Icons.check,
                color: colors.primaryContainer,
                alignment: Alignment.centerLeft,
              ),
              secondaryBackground: _SwipeHint(
                label: 'Skip',
                icon: Icons.close,
                color: colors.surfaceContainerHighest,
                alignment: Alignment.centerRight,
              ),
              child: _RecipeCard(recipe: recipe),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onSkip,
                  icon: const Icon(Icons.close),
                  label: const Text('Skip'),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: FilledButton.tonalIcon(
                  onPressed: onCook,
                  icon: const Icon(Icons.check),
                  label: const Text('Cook'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _RecipeCard extends StatelessWidget {
  const _RecipeCard({required this.recipe});

  final Recipe recipe;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final photo = recipe.photoPath;
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: photo == null
                ? const Icon(Icons.restaurant, size: 96)
                : Image.file(
                    File(photo),
                    fit: BoxFit.cover,
                    semanticLabel: 'Photo of ${recipe.title}',
                    errorBuilder: (_, _, _) =>
                        const Icon(Icons.restaurant, size: 96),
                  ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(recipe.title, style: textTheme.headlineSmall),
                Text(formatPortions(recipe.portions)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SwipeHint extends StatelessWidget {
  const _SwipeHint({
    required this.label,
    required this.icon,
    required this.color,
    required this.alignment,
  });

  final String label;
  final IconData icon;
  final Color color;
  final Alignment alignment;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 24),
      alignment: alignment,
      child: ExcludeSemantics(child: Icon(icon, size: 48)),
    );
  }
}
