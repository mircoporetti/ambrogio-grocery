import 'dart:io';

import 'package:flutter/material.dart';

import '../application/create_recipe.dart';
import '../application/pick_recipe_photo.dart';
import '../domain/recipe.dart';
import 'recipe_form_page.dart';
import 'recipe_form_view_model.dart';
import 'recipe_list_view_model.dart';

class RecipeListPage extends StatelessWidget {
  const RecipeListPage({
    super.key,
    required this.viewModel,
    required this.createRecipe,
    required this.pickRecipePhoto,
  });

  final RecipeListViewModel viewModel;
  final CreateRecipe createRecipe;
  final PickRecipePhoto pickRecipePhoto;

  // The form saves the recipe itself; the list updates by watching storage.
  void _openNewRecipeForm(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => RecipeFormPage(
          viewModel: RecipeFormViewModel(createRecipe, pickRecipePhoto),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Recipes')),
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
            itemBuilder: (_, i) => _RecipeTile(recipe: viewModel.recipes[i]),
          );
        },
      ),
    );
  }
}

class _RecipeTile extends StatelessWidget {
  const _RecipeTile({required this.recipe});

  final Recipe recipe;

  String get _subtitle {
    final portions = recipe.portions == 1
        ? '1 portion'
        : '${recipe.portions} portions';
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
    );
  }
}
