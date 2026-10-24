import 'package:flutter/material.dart';

import 'app.dart';
import 'database/app_database.dart';
import 'recipes/data/drift_recipe_storage_adapter.dart';

void main() {
  final database = AppDatabase.onDevice();
  runApp(AmbrogioApp(recipeStorage: DriftRecipeStorageAdapter(database)));
}
