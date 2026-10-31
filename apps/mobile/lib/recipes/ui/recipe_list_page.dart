import 'package:flutter/material.dart';

import '../../shared/ui/readable_width.dart';

import '../application/create_recipe.dart';
import '../application/delete_recipe.dart';
import '../application/pick_recipe_photo.dart';
import '../application/update_recipe.dart';
import '../application/watch_recipe.dart';
import '../../l10n/app_localizations.dart';
import '../domain/recipe.dart';
import 'confirm_delete_recipe.dart';
import 'recipe_detail_page.dart';
import 'recipe_detail_view_model.dart';
import 'recipe_form_page.dart';
import 'photo_image.dart';
import 'recipe_form_view_model.dart';
import 'recipe_list_view_model.dart';

class RecipeListPage extends StatelessWidget {
  const RecipeListPage({
    super.key,
    required this.viewModel,
    required this.createRecipe,
    required this.pickRecipePhoto,
    required this.watchRecipe,
    required this.deleteRecipe,
    required this.updateRecipe,
    required this.groceryListsPage,
    required this.settingsPage,
  });

  final RecipeListViewModel viewModel;
  final CreateRecipe createRecipe;
  final PickRecipePhoto pickRecipePhoto;
  final WatchRecipe watchRecipe;
  final DeleteRecipe deleteRecipe;
  final UpdateRecipe updateRecipe;
  final Widget Function() groceryListsPage;
  final Widget Function() settingsPage;

  // The form saves the recipe itself; the list updates by watching storage.
  void _openNewRecipeForm(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => RecipeFormPage(
          viewModel: RecipeFormViewModel.create(createRecipe, pickRecipePhoto),
        ),
      ),
    );
  }

  void _openGroceryLists(BuildContext context) {
    Navigator.of(
      context,
    ).push(MaterialPageRoute<void>(builder: (_) => groceryListsPage()));
  }

  void _openSettings(BuildContext context) {
    Navigator.of(
      context,
    ).push(MaterialPageRoute<void>(builder: (_) => settingsPage()));
  }

  void _openRecipe(BuildContext context, Recipe recipe) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => RecipeDetailPage(
          viewModel: RecipeDetailViewModel(
            watchRecipe,
            deleteRecipe,
            recipe.id,
          ),
          editFormFor: (recipe) =>
              RecipeFormViewModel.edit(updateRecipe, pickRecipePhoto, recipe),
        ),
      ),
    );
  }

  Future<bool> _confirmAndDelete(BuildContext context, Recipe recipe) async {
    if (!await confirmDeleteRecipe(context, recipe)) return false;
    return viewModel.delete(recipe);
  }

  PreferredSizeWidget? _errorBanner(BuildContext context) {
    final error = viewModel.error;
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

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: viewModel,
      builder: (context, _) => _scaffold(context),
    );
  }

  static const _gridFrom = 840.0;

  Widget _grid(BuildContext context) => ReadableWidth(
    maxWidth: ReadableWidth.grid,
    child: GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 300,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        childAspectRatio: 0.85,
      ),
      itemCount: viewModel.recipes.length,
      itemBuilder: (context, i) {
        final recipe = viewModel.recipes[i];
        return _RecipeGridCard(
          recipe: recipe,
          onTap: () => _openRecipe(context, recipe),
        );
      },
    ),
  );

  Widget _scaffold(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        bottom: _errorBanner(context),
        title: Text(l10n.recipes),
        actions: [
          IconButton(
            tooltip: l10n.groceryLists,
            icon: const Icon(Icons.shopping_cart_outlined),
            onPressed: () => _openGroceryLists(context),
          ),
          IconButton(
            tooltip: l10n.settings,
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => _openSettings(context),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        tooltip: l10n.newRecipe,
        onPressed: () => _openNewRecipeForm(context),
        child: const Icon(Icons.add),
      ),
      body: switch ((viewModel.loading, viewModel.recipes.isEmpty)) {
        (true, _) => const Center(child: CircularProgressIndicator()),
        (false, true) => Center(child: Text(l10n.noRecipesYet)),
        (false, false) when MediaQuery.sizeOf(context).width >= _gridFrom =>
          _grid(context),
        (false, false) => ListView.builder(
          itemCount: viewModel.recipes.length,
          itemBuilder: (context, i) {
            final recipe = viewModel.recipes[i];
            return Dismissible(
              key: ValueKey(recipe.id),
              direction: DismissDirection.endToStart,
              confirmDismiss: (_) => _confirmAndDelete(context, recipe),
              background: Container(
                color: colors.errorContainer,
                padding: const EdgeInsets.symmetric(horizontal: 24),
                alignment: Alignment.centerRight,
                child: ExcludeSemantics(
                  child: Icon(
                    Icons.delete_outline,
                    color: colors.onErrorContainer,
                  ),
                ),
              ),
              child: _RecipeTile(
                recipe: recipe,
                onTap: () => _openRecipe(context, recipe),
              ),
            );
          },
        ),
      },
    );
  }
}

String _subtitle(AppLocalizations l10n, Recipe recipe) {
  final portions = l10n.portions(recipe.portions);
  if (recipe.categories.isEmpty) return portions;
  return '$portions · ${recipe.categories.join(', ')}';
}

class _RecipeTile extends StatelessWidget {
  const _RecipeTile({required this.recipe, required this.onTap});

  final Recipe recipe;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final photo = recipe.photo?.path;
    return ListTile(
      leading: CircleAvatar(
        backgroundImage: photo == null ? null : photoImage(photo),
        child: photo == null ? const Icon(Icons.restaurant) : null,
      ),
      title: Text(recipe.title),
      subtitle: Text(_subtitle(AppLocalizations.of(context), recipe)),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}

class _RecipeGridCard extends StatelessWidget {
  const _RecipeGridCard({required this.recipe, required this.onTap});

  final Recipe recipe;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context);
    final photo = recipe.photo?.path;
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: photo == null
                  ? const Icon(Icons.restaurant, size: 64)
                  : Image(
                      image: photoImage(photo),
                      fit: BoxFit.cover,
                      semanticLabel: l10n.photoOf(recipe.title),
                      errorBuilder: (_, _, _) =>
                          const Icon(Icons.restaurant, size: 64),
                    ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    recipe.title,
                    style: textTheme.titleMedium,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    _subtitle(l10n, recipe),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
