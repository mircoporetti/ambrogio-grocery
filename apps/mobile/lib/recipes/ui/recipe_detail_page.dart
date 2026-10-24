import 'dart:io';

import 'package:flutter/material.dart';

import '../domain/recipe.dart';
import 'formatting.dart';
import 'recipe_detail_view_model.dart';

class RecipeDetailPage extends StatefulWidget {
  const RecipeDetailPage({super.key, required this.viewModel});

  final RecipeDetailViewModel viewModel;

  @override
  State<RecipeDetailPage> createState() => _RecipeDetailPageState();
}

class _RecipeDetailPageState extends State<RecipeDetailPage> {
  @override
  void dispose() {
    widget.viewModel.dispose();
    super.dispose();
  }

  Future<void> _confirmAndDelete(Recipe recipe) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete ${recipe.title}?'),
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
    if (confirmed != true) return;
    final deleted = await widget.viewModel.delete();
    if (deleted && mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.viewModel,
      builder: (context, _) {
        final recipe = widget.viewModel.recipe;
        final error = widget.viewModel.error;
        final colors = Theme.of(context).colorScheme;
        return Scaffold(
          appBar: AppBar(
            title: Text(recipe?.title ?? ''),
            actions: [
              if (recipe != null)
                IconButton(
                  tooltip: 'Delete recipe',
                  icon: const Icon(Icons.delete_outline),
                  onPressed: widget.viewModel.deleting
                      ? null
                      : () => _confirmAndDelete(recipe),
                ),
            ],
            bottom: error == null
                ? null
                : PreferredSize(
                    preferredSize: const Size.fromHeight(44),
                    child: Container(
                      width: double.infinity,
                      color: colors.errorContainer,
                      padding: const EdgeInsets.all(12),
                      child: Semantics(
                        liveRegion: true,
                        child: Text(
                          error,
                          style: TextStyle(color: colors.onErrorContainer),
                        ),
                      ),
                    ),
                  ),
          ),
          body: switch ((widget.viewModel.loading, recipe)) {
            (true, _) => const Center(child: CircularProgressIndicator()),
            (false, null) => const Center(
              child: Text('This recipe no longer exists'),
            ),
            (false, final Recipe recipe) => _RecipeDetails(recipe: recipe),
          },
        );
      },
    );
  }
}

class _RecipeDetails extends StatelessWidget {
  const _RecipeDetails({required this.recipe});

  final Recipe recipe;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final photo = recipe.photoPath;
    final procedure = recipe.procedure;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        if (photo != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.file(
                File(photo),
                height: 220,
                fit: BoxFit.cover,
                semanticLabel: 'Photo of ${recipe.title}',
                errorBuilder: (_, _, _) => const SizedBox.shrink(),
              ),
            ),
          ),
        Text(formatPortions(recipe.portions), style: textTheme.titleMedium),
        if (recipe.categories.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final category in recipe.categories)
                  Chip(label: Text(category)),
              ],
            ),
          ),
        const SizedBox(height: 24),
        Text('Ingredients', style: textTheme.titleLarge),
        for (final ingredient in recipe.ingredients)
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(ingredient.name),
            trailing: Text(formatQuantity(ingredient)),
          ),
        if (procedure != null) ...[
          const SizedBox(height: 24),
          Text('Procedure', style: textTheme.titleLarge),
          const SizedBox(height: 8),
          Text(procedure, style: textTheme.bodyLarge),
        ],
      ],
    );
  }
}
