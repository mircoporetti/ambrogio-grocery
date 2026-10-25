import 'package:flutter/material.dart';

import 'grocery/application/create_grocery_list.dart';
import 'grocery/application/find_grocery_list.dart';
import 'grocery/application/get_current_week.dart';
import 'grocery/application/watch_grocery_list.dart';
import 'grocery/application/watch_upcoming_grocery_lists.dart';
import 'grocery/data/system_clock_adapter.dart';
import 'grocery/domain/clock_port.dart';
import 'grocery/domain/grocery_list_storage_port.dart';
import 'grocery/ui/grocery_list_view_model.dart';
import 'grocery/ui/grocery_lists_page.dart';
import 'grocery/ui/grocery_lists_view_model.dart';
import 'grocery/ui/plan_week_view_model.dart';
import 'recipes/application/create_recipe.dart';
import 'recipes/application/delete_recipe.dart';
import 'recipes/application/list_recipes.dart';
import 'recipes/application/pick_recipe_photo.dart';
import 'recipes/application/update_recipe.dart';
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
    required this.groceryListStorage,
    this.clock,
    this.photoPicker,
    this.photoStorage,
  });

  final RecipeStoragePort recipeStorage;
  final GroceryListStoragePort groceryListStorage;
  final ClockPort? clock;
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
  late final _photoStorage = widget.photoStorage ?? FilePhotoStorageAdapter();
  late final _deleteRecipe = DeleteRecipe(widget.recipeStorage, _photoStorage);
  late final _updateRecipe = UpdateRecipe(widget.recipeStorage, _photoStorage);
  late final _listRecipes = ListRecipes(widget.recipeStorage);
  late final _clock = widget.clock ?? SystemClockAdapter();
  late final _getCurrentWeek = GetCurrentWeek(_clock);
  late final _createGroceryList = CreateGroceryList(widget.groceryListStorage);
  late final _findGroceryList = FindGroceryList(widget.groceryListStorage);
  late final _watchGroceryList = WatchGroceryList(widget.groceryListStorage);
  late final _watchUpcomingGroceryLists = WatchUpcomingGroceryLists(
    widget.groceryListStorage,
    _clock,
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
        updateRecipe: _updateRecipe,
        groceryListsPage: () => GroceryListsPage(
          viewModel: GroceryListsViewModel(
            _watchUpcomingGroceryLists,
            _getCurrentWeek,
          ),
          planWeekViewModel: () => PlanWeekViewModel(
            _listRecipes,
            _createGroceryList,
            _findGroceryList,
            _getCurrentWeek,
          ),
          groceryListViewModel: (week) =>
              GroceryListViewModel(_watchGroceryList, week),
        ),
      ),
    );
  }
}
