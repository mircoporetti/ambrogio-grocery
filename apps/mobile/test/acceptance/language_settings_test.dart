import 'package:ambrogio_grocery/recipes/data/drift_recipe_storage_adapter.dart';
import 'package:ambrogio_grocery/settings/data/shared_preferences_language_preference_adapter.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'support/failing_language_preference_adapter.dart';
import 'support/language_robot.dart';
import 'support/recipe_robot.dart';
import 'support/settings_robot.dart';
import 'support/test_database.dart';
import 'support/test_preferences.dart';

void main() {
  late DriftRecipeStorageAdapter recipes;
  late SharedPreferencesAsync preferences;
  late SettingsRobot robot;

  setUp(() {
    recipes = DriftRecipeStorageAdapter(
      openInMemoryDatabase(),
      documentsDir: testDocumentsDir,
    );
    preferences = inMemoryPreferences();
  });

  Future<void> launchApp(
    WidgetTester tester, {
    FailingLanguagePreferenceAdapter? failingPreference,
  }) async {
    await RecipeRobot(tester).launchApp(
      recipes,
      languagePreference:
          failingPreference ??
          SharedPreferencesLanguagePreferenceAdapter(preferences),
    );
    robot = SettingsRobot(tester);
  }

  testWidgets('by default the app follows the phone language', (tester) async {
    await launchApp(tester);

    await robot.openSettings();
    expect(robot.languageSetting(), 'System default');

    await robot.openLanguage();
    expect(robot.languages, ['System default', 'English', 'Italiano']);
    expect(robot.tickedLanguage, 'System default');
  });

  testWidgets('choosing a language switches the whole app to it', (
    tester,
  ) async {
    await launchApp(tester);
    await robot.openSettings();
    await robot.openLanguage();

    await robot.chooseLanguage('Italiano');

    expect(find.text('Impostazioni'), findsOneWidget);
    expect(robot.languageSetting(label: 'Lingua'), 'Italiano');
    await robot.openLanguage(label: 'Lingua');
    expect(robot.languages, ['Predefinita di sistema', 'English', 'Italiano']);
    expect(robot.tickedLanguage, 'Italiano');
    await robot.goBack();
    await robot.goBack();
    expect(find.text('Ricette'), findsOneWidget);
  });

  testWidgets('the chosen language is kept after restarting the app', (
    tester,
  ) async {
    await launchApp(tester);
    await robot.openSettings();
    await robot.openLanguage();
    await robot.chooseLanguage('Italiano');
    await RecipeRobot(tester).closeApp();

    await launchApp(tester);

    expect(find.text('Ricette'), findsOneWidget);
  });

  testWidgets('choosing system default goes back to the phone language', (
    tester,
  ) async {
    LanguageRobot(tester).setPhoneLanguage(const Locale('it', 'IT'));
    await launchApp(tester);
    await robot.openSettings(tooltip: 'Impostazioni');
    await robot.openLanguage(label: 'Lingua');
    await robot.chooseLanguage('English');
    expect(find.text('Settings'), findsOneWidget);

    await robot.openLanguage();
    await robot.chooseLanguage('System default');

    expect(find.text('Impostazioni'), findsOneWidget);
    expect(robot.languageSetting(label: 'Lingua'), 'Predefinita di sistema');
  });

  testWidgets('if saving fails, the language stays and an error is shown', (
    tester,
  ) async {
    final failingPreference = FailingLanguagePreferenceAdapter(
      SharedPreferencesLanguagePreferenceAdapter(preferences),
    )..failSaves = true;
    await launchApp(tester, failingPreference: failingPreference);
    await robot.openSettings();
    await robot.openLanguage();

    await robot.chooseLanguage('Italiano');

    expect(
      find.text('Could not change the language. Please try again.'),
      findsOneWidget,
    );
    expect(robot.tickedLanguage, 'System default');

    failingPreference.failSaves = false;
    await robot.chooseLanguage('Italiano');

    expect(find.text('Impostazioni'), findsOneWidget);
  });
}
