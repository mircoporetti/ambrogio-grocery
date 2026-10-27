import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'account/data/http_account_api_adapter.dart';
import 'account/data/secure_storage_session_adapter.dart';
import 'account/data/shared_preferences_log_in_prompt_adapter.dart';
import 'app.dart';
import 'database/app_database.dart';
import 'grocery/data/drift_grocery_list_storage_adapter.dart';
import 'recipes/data/drift_recipe_storage_adapter.dart';
import 'recipes/data/http_recipe_sync_api_adapter.dart';
import 'settings/data/shared_preferences_language_preference_adapter.dart';

const _apiUrl = String.fromEnvironment(
  'API_URL',
  defaultValue: 'http://localhost:8080',
);

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final documents = await getApplicationDocumentsDirectory();
  final database = AppDatabase.onDevice();
  final recipes = DriftRecipeStorageAdapter(
    database,
    documentsDir: documents.path,
  );
  final apiUrl = Uri.parse(_apiUrl);
  final client = http.Client();
  runApp(
    AmbrogioApp(
      recipeStorage: recipes,
      recipeSyncStorage: recipes,
      recipeSyncApi: HttpRecipeSyncApiAdapter(apiUrl, client),
      groceryListStorage: DriftGroceryListStorageAdapter(database),
      languagePreference: SharedPreferencesLanguagePreferenceAdapter(
        SharedPreferencesAsync(),
      ),
      accountApi: HttpAccountApiAdapter(apiUrl, client),
      sessionStorage: SecureStorageSessionAdapter(const FlutterSecureStorage()),
      logInPrompt: SharedPreferencesLogInPromptAdapter(
        SharedPreferencesAsync(),
      ),
    ),
  );
}
