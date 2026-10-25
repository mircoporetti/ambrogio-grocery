import 'dart:io';

import 'package:flutter/material.dart';

import '../application/create_recipe.dart';
import '../application/delete_recipe.dart';
import '../application/pick_recipe_photo.dart';
import '../application/update_recipe.dart';
import '../application/watch_recipe.dart';
import '../domain/recipe.dart';
import 'formatting.dart';
import 'recipe_detail_page.dart';
import 'recipe_detail_view_model.dart';
import 'recipe_form_page.dart';
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
  });

  final RecipeListViewModel viewModel;
  final CreateRecipe createRecipe;
  final PickRecipePhoto pickRecipePhoto;
  final WatchRecipe watchRecipe;
  final DeleteRecipe deleteRecipe;
  final UpdateRecipe updateRecipe;
  final Widget Function() groceryListsPage;

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Recipes'),
        actions: [
          IconButton(
            tooltip: 'Grocery lists',
            icon: const Icon(Icons.shopping_cart_outlined),
            onPressed: () => _openGroceryLists(context),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        tooltip: 'New recipe',
        onPressed: () => _openNewRecipeForm(context),
        child: const Icon(Icons.add),
      ),
      body: ListenableBuilder(
        listenable: viewModel,
        builder: (context, _) {
          if (viewModel.loading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (viewModel.recipes.isEmpty) {
            return const Center(child: Text('No recipes yet'));
          }
          return ListView.builder(
            itemCount: viewModel.recipes.length,
            itemBuilder: (context, i) {
              final recipe = viewModel.recipes[i];
              return _RecipeTile(
                recipe: recipe,
                onTap: () => _openRecipe(context, recipe),
              );
            },
          );
        },
      ),
    );
  }
}

class _RecipeTile extends StatelessWidget {
  const _RecipeTile({required this.recipe, required this.onTap});

  final Recipe recipe;
  final VoidCallback onTap;

  String get _subtitle {
    final portions = formatPortions(recipe.portions);
    if (recipe.categories.isEmpty) return portions;
    return '$portions · ${recipe.categories.join(', ')}';
  }

  @override
  Widget build(BuildContext context) {
    final photo = recipe.photoPath;
    return ListTile(
      leading: CircleAvatar(
        backgroundImage: photo == null ? null : FileImage(File(photo)),
        child: photo == null ? const Icon(Icons.restaurant) : null,
      ),
      title: Text(recipe.title),
      subtitle: Text(_subtitle),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}
