import 'package:flutter/material.dart';

import 'recipes/application/create_recipe.dart';
import 'recipes/application/delete_recipe.dart';
import 'recipes/application/pick_recipe_photo.dart';
import 'recipes/application/watch_recipe.dart';
import 'recipes/application/watch_recipes.dart';
import 'recipes/data/file_photo_storage_adapter.dart';
import 'recipes/data/image_picker_photo_picker_adapter.dart';
import 'recipes/domain/photo_picker_port.dart';
import 'recipes/domain/photo_storage_port.dart';
import 'recipes/domain/recipe_storage_port.dart';
import 'recipes/ui/recipe_list_page.dart';
import 'recipes/ui/recipe_list_view_model.dart';

class AmbrogioApp extends StatefulWidget {
  const AmbrogioApp({
    super.key,
    required this.recipeStorage,
    this.photoPicker,
    this.photoStorage,
  });

  final RecipeStoragePort recipeStorage;
  final PhotoPickerPort? photoPicker;
  final PhotoStoragePort? photoStorage;

  @override
  State<AmbrogioApp> createState() => _AmbrogioAppState();
}

class _AmbrogioAppState extends State<AmbrogioApp> {
  late final _createRecipe = CreateRecipe(widget.recipeStorage);
  late final _pickRecipePhoto = PickRecipePhoto(
    widget.photoPicker ?? ImagePickerPhotoPickerAdapter(),
  );
  late final _watchRecipe = WatchRecipe(widget.recipeStorage);
  late final _deleteRecipe = DeleteRecipe(
    widget.recipeStorage,
    widget.photoStorage ?? FilePhotoStorageAdapter(),
  );
  late final _recipeList = RecipeListViewModel(
    WatchRecipes(widget.recipeStorage),
  );

  @override
  void dispose() {
    _recipeList.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ambrogio Grocery',
      theme: ThemeData(colorSchemeSeed: Colors.green),
      home: RecipeListPage(
        viewModel: _recipeList,
        createRecipe: _createRecipe,
        pickRecipePhoto: _pickRecipePhoto,
        watchRecipe: _watchRecipe,
        deleteRecipe: _deleteRecipe,
      ),
    );
  }
}
