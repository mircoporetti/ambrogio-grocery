import 'package:flutter/material.dart';

import '../../shared/ui/readable_width.dart';

import '../../l10n/app_localizations.dart';
import '../domain/recipe.dart';
import 'confirm_delete_recipe.dart';
import 'formatting.dart';
import 'photo_image.dart';
import 'recipe_detail_view_model.dart';
import 'recipe_form_page.dart';
import 'recipe_form_view_model.dart';

class RecipeDetailPage extends StatefulWidget {
  const RecipeDetailPage({
    super.key,
    required this.viewModel,
    required this.editFormFor,
  });

  final RecipeDetailViewModel viewModel;
  final RecipeFormViewModel Function(Recipe recipe) editFormFor;

  @override
  State<RecipeDetailPage> createState() => _RecipeDetailPageState();
}

class _RecipeDetailPageState extends State<RecipeDetailPage> {
  @override
  void dispose() {
    widget.viewModel.dispose();
    super.dispose();
  }

  void _openEditForm(Recipe recipe) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => RecipeFormPage(viewModel: widget.editFormFor(recipe)),
      ),
    );
  }

  Future<void> _confirmAndDelete(Recipe recipe) async {
    if (!await confirmDeleteRecipe(context, recipe)) return;
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
        final l10n = AppLocalizations.of(context);
        return Scaffold(
          appBar: AppBar(
            title: Text(recipe?.title ?? ''),
            actions: [
              if (recipe != null)
                IconButton(
                  tooltip: l10n.editRecipe,
                  icon: const Icon(Icons.edit_outlined),
                  onPressed: widget.viewModel.deleting
                      ? null
                      : () => _openEditForm(recipe),
                ),
              if (recipe != null)
                IconButton(
                  tooltip: l10n.deleteRecipe,
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
                          error.message(l10n),
                          style: TextStyle(color: colors.onErrorContainer),
                        ),
                      ),
                    ),
                  ),
          ),
          body: ReadableWidth(
            maxWidth: ReadableWidth.list,
            child: switch ((widget.viewModel.loading, recipe)) {
              (true, _) => const Center(child: CircularProgressIndicator()),
              (false, null) => Center(child: Text(l10n.recipeNoLongerExists)),
              (false, final Recipe recipe) => _RecipeDetails(recipe: recipe),
            },
          ),
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
    final l10n = AppLocalizations.of(context);
    final photo = recipe.photo?.path;
    final procedure = recipe.procedure;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        if (photo != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image(
                image: photoImage(photo),
                height: 220,
                fit: BoxFit.cover,
                semanticLabel: l10n.photoOf(recipe.title),
                errorBuilder: (_, _, _) => const SizedBox.shrink(),
              ),
            ),
          ),
        Text(l10n.portions(recipe.portions), style: textTheme.titleMedium),
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
        Text(l10n.ingredients, style: textTheme.titleLarge),
        for (final ingredient in recipe.ingredients)
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(ingredient.name),
            trailing: Text(formatQuantity(l10n, ingredient)),
          ),
        if (procedure != null) ...[
          const SizedBox(height: 24),
          Text(l10n.procedure, style: textTheme.titleLarge),
          const SizedBox(height: 8),
          Text(procedure, style: textTheme.bodyLarge),
        ],
      ],
    );
  }
}
