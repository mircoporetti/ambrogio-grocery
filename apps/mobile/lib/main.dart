import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

import 'app.dart';
import 'database/app_database.dart';
import 'recipes/data/drift_recipe_storage_adapter.dart';

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
    ),
  );
}
