import 'package:flutter/material.dart';

import 'account/application/answer_log_in_prompt.dart';
import 'account/application/create_account.dart';
import 'account/application/log_in.dart';
import 'account/application/log_out.dart';
import 'account/application/should_ask_to_log_in.dart';
import 'account/application/watch_session.dart';
import 'account/domain/account_api_port.dart';
import 'account/domain/log_in_prompt_port.dart';
import 'account/domain/session_storage_port.dart';
import 'account/ui/account_view_model.dart';
import 'account/ui/log_in_prompt.dart';
import 'account/ui/log_in_prompt_view_model.dart';
import 'account/ui/log_in_view_model.dart';
import 'grocery/application/create_grocery_list.dart';
import 'grocery/application/delete_grocery_list.dart';
import 'grocery/application/find_grocery_list.dart';
import 'grocery/application/get_current_week.dart';
import 'grocery/application/tick_grocery_item.dart';
import 'grocery/application/watch_grocery_list.dart';
import 'grocery/application/watch_upcoming_grocery_lists.dart';
import 'grocery/data/system_clock_adapter.dart';
import 'grocery/domain/clock_port.dart';
import 'grocery/domain/grocery_list_storage_port.dart';
import 'grocery/ui/grocery_list_view_model.dart';
import 'grocery/ui/grocery_lists_page.dart';
import 'grocery/ui/grocery_lists_view_model.dart';
import 'grocery/ui/plan_week_view_model.dart';
import 'l10n/app_localizations.dart';
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
import 'settings/application/change_language.dart';
import 'settings/application/watch_language_preference.dart';
import 'settings/domain/language_preference_port.dart';
import 'settings/ui/app_language_view_model.dart';
import 'settings/ui/language_view_model.dart';
import 'settings/ui/settings_page.dart';
import 'settings/ui/settings_view_model.dart';

class AmbrogioApp extends StatefulWidget {
  const AmbrogioApp({
    super.key,
    required this.recipeStorage,
    required this.groceryListStorage,
    required this.languagePreference,
    required this.accountApi,
    required this.sessionStorage,
    required this.logInPrompt,
    this.clock,
    this.photoPicker,
    this.photoStorage,
  });

  final RecipeStoragePort recipeStorage;
  final GroceryListStoragePort groceryListStorage;
  final LanguagePreferencePort languagePreference;
  final AccountApiPort accountApi;
  final SessionStoragePort sessionStorage;
  final LogInPromptPort logInPrompt;
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
  late final _createGroceryList = CreateGroceryList(
    widget.groceryListStorage,
    _clock,
  );
  late final _findGroceryList = FindGroceryList(widget.groceryListStorage);
  late final _watchGroceryList = WatchGroceryList(widget.groceryListStorage);
  late final _tickGroceryItem = TickGroceryItem(widget.groceryListStorage);
  late final _deleteGroceryList = DeleteGroceryList(widget.groceryListStorage);
  late final _watchUpcomingGroceryLists = WatchUpcomingGroceryLists(
    widget.groceryListStorage,
    _clock,
  );
  late final _watchLanguagePreference = WatchLanguagePreference(
    widget.languagePreference,
  );
  late final _changeLanguage = ChangeLanguage(widget.languagePreference);
  late final _appLanguage = AppLanguageViewModel(_watchLanguagePreference);
  late final _logIn = LogIn(widget.accountApi, widget.sessionStorage);
  late final _createAccount = CreateAccount(widget.accountApi, _logIn);
  late final _logOut = LogOut(widget.accountApi, widget.sessionStorage);
  late final _watchSession = WatchSession(widget.sessionStorage);
  late final _logInPrompt = LogInPromptViewModel(
    ShouldAskToLogIn(widget.logInPrompt, widget.sessionStorage),
    AnswerLogInPrompt(widget.logInPrompt),
  );
  late final _recipeList = RecipeListViewModel(
    WatchRecipes(widget.recipeStorage),
    _deleteRecipe,
  );

  @override
  void dispose() {
    _recipeList.dispose();
    _appLanguage.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _appLanguage,
      builder: (context, _) =>
          _appLanguage.ready ? _app() : const SizedBox.shrink(),
    );
  }

  Widget _app() {
    return MaterialApp(
      locale: _appLanguage.locale,
      onGenerateTitle: (context) => AppLocalizations.of(context).appTitle,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      theme: ThemeData(colorSchemeSeed: Colors.green),
      home: LogInPrompt(
        viewModel: _logInPrompt,
        logInViewModel: () => LogInViewModel(_logIn, _createAccount),
        child: RecipeListPage(
          viewModel: _recipeList,
          createRecipe: _createRecipe,
          pickRecipePhoto: _pickRecipePhoto,
          watchRecipe: _watchRecipe,
          deleteRecipe: _deleteRecipe,
          updateRecipe: _updateRecipe,
          settingsPage: () => SettingsPage(
            viewModel: SettingsViewModel(_watchLanguagePreference),
            languageViewModel: () =>
                LanguageViewModel(_watchLanguagePreference, _changeLanguage),
            accountViewModel: AccountViewModel(_watchSession, _logOut),
            logInViewModel: () => LogInViewModel(_logIn, _createAccount),
          ),
          groceryListsPage: () => GroceryListsPage(
            viewModel: GroceryListsViewModel(
              _watchUpcomingGroceryLists,
              _getCurrentWeek,
              _deleteGroceryList,
            ),
            planWeekViewModel: () => PlanWeekViewModel(
              _listRecipes,
              _createGroceryList,
              _findGroceryList,
              _getCurrentWeek,
            ),
            groceryListViewModel: (week) => GroceryListViewModel(
              _watchGroceryList,
              _tickGroceryItem,
              _deleteGroceryList,
              week,
            ),
          ),
        ),
      ),
    );
  }
}
