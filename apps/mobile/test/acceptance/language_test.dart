import 'package:ambrogio_grocery/database/app_database.dart';
import 'package:ambrogio_grocery/grocery/data/drift_grocery_list_storage_adapter.dart';
import 'package:ambrogio_grocery/recipes/data/drift_recipe_storage_adapter.dart';
import 'package:ambrogio_grocery/recipes/domain/ingredient.dart';
import 'package:ambrogio_grocery/recipes/domain/recipe.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/failing_recipe_storage_adapter.dart';
import 'support/fixed_clock_adapter.dart';
import 'support/language_robot.dart';
import 'support/recipe_robot.dart';
import 'support/test_database.dart';

void main() {
  const italian = Locale('it', 'IT');

  late AppDatabase db;
  late DriftRecipeStorageAdapter recipes;
  late DriftGroceryListStorageAdapter lists;

  setUp(() {
    db = openInMemoryDatabase();
    recipes = DriftRecipeStorageAdapter(db, documentsDir: testDocumentsDir);
    lists = DriftGroceryListStorageAdapter(db);
  });

  Future<void> givenRecipe(
    String title,
    List<Ingredient> ingredients, {
    int portions = 2,
  }) => recipes.save(
    Recipe(title: title, portions: portions, ingredients: ingredients),
  );

  testWidgets('on an Italian phone, recipes are written in Italian', (
    tester,
  ) async {
    final robot = LanguageRobot(tester)..setPhoneLanguage(italian);
    await RecipeRobot(tester).launchApp(recipes, groceryListStorage: lists);

    expect(find.text('Ricette'), findsOneWidget);
    expect(find.text('Ancora nessuna ricetta'), findsOneWidget);

    await robot.tapButton('Nuova ricetta');
    expect(find.text('Nuova ricetta'), findsOneWidget);
    await robot.tapText('Salva');
    expect(find.text('Il titolo è obbligatorio'), findsOneWidget);
    expect(
      find.text('Le porzioni devono essere un numero intero di almeno 1'),
      findsOneWidget,
    );
    expect(find.text('Aggiungi almeno un ingrediente'), findsOneWidget);

    await robot.enter('Titolo', 'Carbonara');
    await robot.enter('Porzioni', '4');
    await robot.enter('Ingrediente', 'Latte');
    await robot.enter('Quantità', '1,5');
    await robot.tapText('ml');
    await robot.tapText('Aggiungi ingrediente');
    await robot.enter('Procedimento (facoltativo)', 'Mescolare.');
    await robot.enter('Categoria', 'Pasta');
    await robot.tapText('Aggiungi categoria');
    await robot.tapText('Salva');

    expect(find.text('4 porzioni · Pasta'), findsOneWidget);

    await robot.tapText('Carbonara');
    expect(find.text('Ingredienti'), findsOneWidget);
    expect(find.text('1,5 ml'), findsOneWidget);
    expect(find.text('Procedimento'), findsOneWidget);

    await robot.tapButton('Modifica ricetta');
    expect(find.text('Modifica ricetta'), findsOneWidget);
  });

  testWidgets('on an Italian phone, the week is planned in Italian', (
    tester,
  ) async {
    await givenRecipe('Carbonara', [
      Ingredient(name: 'Spaghetti', quantity: 320, unit: MeasureUnit.grams),
      Ingredient(name: 'Olio', quantity: 0.5, unit: MeasureUnit.milliliters),
    ], portions: 1);
    final robot = LanguageRobot(tester)..setPhoneLanguage(italian);
    await RecipeRobot(tester).launchApp(recipes, groceryListStorage: lists);

    await robot.tapButton('Liste della spesa');
    expect(find.text('Ancora nessuna lista della spesa'), findsOneWidget);

    await robot.tapButton('Pianifica una settimana');
    expect(find.text('Pianifica la settimana'), findsOneWidget);
    expect(find.text('19 – 25 ott'), findsOneWidget);
    expect(find.text('1 di 1'), findsOneWidget);
    expect(find.text('1 porzione'), findsOneWidget);
    expect(find.text('Nessuna ricetta scelta'), findsOneWidget);

    await robot.tapButton('Settimana successiva');
    expect(find.text('26 ott – 1 nov'), findsOneWidget);
    await robot.tapButton('Settimana precedente');

    await robot.tapText('Cucina');
    expect(find.text('1 ricetta scelta'), findsOneWidget);
    expect(find.text('Hai visto tutte le tue ricette'), findsOneWidget);

    await robot.tapText('Crea la lista della spesa');
    expect(find.text('Lista della spesa'), findsOneWidget);
    expect(find.text('0,5 ml'), findsOneWidget);
    expect(find.text('320 g'), findsOneWidget);

    await robot.tapButton('Indietro');
    expect(find.text('19 – 25 ott'), findsOneWidget);
    expect(find.text('Questa settimana · 1 ricetta'), findsOneWidget);
  });

  testWidgets('on an Italian phone, errors are shown in Italian', (
    tester,
  ) async {
    await givenRecipe('Carbonara', [
      Ingredient(name: 'Spaghetti', quantity: 320, unit: MeasureUnit.grams),
    ]);
    final failingRecipes = FailingRecipeStorageAdapter(recipes)
      ..failDeletes = true;
    final clock = FixedClockAdapter(DateTime(2026, 10, 25, 23, 59));
    final robot = LanguageRobot(tester)..setPhoneLanguage(italian);
    await RecipeRobot(
      tester,
    ).launchApp(failingRecipes, groceryListStorage: lists, clock: clock);

    await RecipeRobot(tester).swipeToDelete('Carbonara');
    expect(find.text('Eliminare Carbonara?'), findsOneWidget);
    expect(
      find.text('Questa azione non può essere annullata.'),
      findsOneWidget,
    );
    await robot.tapText('Elimina');
    expect(
      find.text('Impossibile eliminare la ricetta. Riprova.'),
      findsOneWidget,
    );

    await robot.tapButton('Liste della spesa');
    await robot.tapButton('Pianifica una settimana');
    await robot.tapText('Cucina');
    clock.today = DateTime(2026, 10, 26, 0, 1);
    await robot.tapText('Crea la lista della spesa');
    expect(
      find.text(
        'La settimana 19 – 25 ott è finita. Scegli una settimana successiva.',
      ),
      findsOneWidget,
    );
  });

  testWidgets('on a phone in an unsupported language, the app is in English', (
    tester,
  ) async {
    LanguageRobot(tester).setPhoneLanguage(const Locale('de', 'DE'));
    await RecipeRobot(tester).launchApp(recipes, groceryListStorage: lists);

    expect(find.text('Recipes'), findsOneWidget);
    expect(find.text('No recipes yet'), findsOneWidget);
  });
}
