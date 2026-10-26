import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app.dart';
import 'database/app_database.dart';
import 'grocery/data/drift_grocery_list_storage_adapter.dart';
import 'recipes/data/drift_recipe_storage_adapter.dart';
import 'settings/data/shared_preferences_language_preference_adapter.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final documents = await getApplicationDocumentsDirectory();
  final database = AppDatabase.onDevice();
  runApp(
    AmbrogioApp(
      recipeStorage: DriftRecipeStorageAdapter(
        database,
        documentsDir: documents.path,
      ),
      groceryListStorage: DriftGroceryListStorageAdapter(database),
      languagePreference: SharedPreferencesLanguagePreferenceAdapter(
        SharedPreferencesAsync(),
      ),
    ),
  );
}
