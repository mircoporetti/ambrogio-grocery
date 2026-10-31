// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Ambrogio Grocery';

  @override
  String get recipes => 'Recipes';

  @override
  String get noRecipesYet => 'No recipes yet';

  @override
  String get newRecipe => 'New recipe';

  @override
  String get editRecipe => 'Edit recipe';

  @override
  String get deleteRecipe => 'Delete recipe';

  @override
  String get recipeNoLongerExists => 'This recipe no longer exists';

  @override
  String photoOf(String title) {
    return 'Photo of $title';
  }

  @override
  String portions(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count portions',
      one: '1 portion',
    );
    return '$_temp0';
  }

  @override
  String get ingredients => 'Ingredients';

  @override
  String get procedure => 'Procedure';

  @override
  String get categories => 'Categories';

  @override
  String get save => 'Save';

  @override
  String get titleLabel => 'Title';

  @override
  String get titleRequired => 'Title is required';

  @override
  String get portionsLabel => 'Portions';

  @override
  String get portionsInvalid => 'Portions must be a whole number of at least 1';

  @override
  String get ingredientLabel => 'Ingredient';

  @override
  String get ingredientNameRequired => 'Ingredient name is required';

  @override
  String get quantityLabel => 'Quantity';

  @override
  String get quantityInvalid => 'Quantity must be a number greater than 0';

  @override
  String get addIngredient => 'Add ingredient';

  @override
  String get addAtLeastOneIngredient => 'Add at least one ingredient';

  @override
  String get procedureOptionalLabel => 'Procedure (optional)';

  @override
  String get categoryLabel => 'Category';

  @override
  String get addCategory => 'Add category';

  @override
  String remove(String name) {
    return 'Remove $name';
  }

  @override
  String get addPhotoOptional => 'Add photo (optional)';

  @override
  String get changePhoto => 'Change photo';

  @override
  String get saveRecipeFailed => 'Could not save the recipe. Please try again.';

  @override
  String get deleteRecipeFailed =>
      'Could not delete the recipe. Please try again.';

  @override
  String confirmDeleteRecipe(String title) {
    return 'Delete $title?';
  }

  @override
  String get cannotBeUndone => 'This cannot be undone.';

  @override
  String get cancel => 'Cancel';

  @override
  String get delete => 'Delete';

  @override
  String get groceryLists => 'Grocery lists';

  @override
  String get groceryList => 'Grocery list';

  @override
  String get noGroceryListsYet => 'No grocery lists yet';

  @override
  String get deleteGroceryList => 'Delete grocery list';

  @override
  String confirmDeleteGroceryList(String week) {
    return 'Delete the list for $week?';
  }

  @override
  String get groceryListNoLongerExists => 'This grocery list no longer exists';

  @override
  String get updateGroceryListFailed =>
      'Could not update the grocery list. Please try again.';

  @override
  String get deleteGroceryListFailed =>
      'Could not delete the grocery list. Please try again.';

  @override
  String get thisWeek => 'This week';

  @override
  String recipeCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count recipes',
      one: '1 recipe',
    );
    return '$_temp0';
  }

  @override
  String get planAWeek => 'Plan a week';

  @override
  String get planTheWeek => 'Plan the week';

  @override
  String get earlierWeek => 'Earlier week';

  @override
  String get laterWeek => 'Later week';

  @override
  String confirmReplaceGroceryList(String week) {
    return 'Replace the list for $week?';
  }

  @override
  String get replaceGroceryListWarning =>
      'The current list of that week will be lost.';

  @override
  String get replace => 'Replace';

  @override
  String recipesChosen(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count recipes chosen',
      one: '1 recipe chosen',
      zero: 'No recipes chosen yet',
    );
    return '$_temp0';
  }

  @override
  String get createGroceryList => 'Create grocery list';

  @override
  String get addRecipesToPlan => 'Add some recipes to plan your week';

  @override
  String get seenAllRecipes => 'You\'ve seen all your recipes';

  @override
  String deckPosition(int position, int total) {
    return '$position of $total';
  }

  @override
  String get skip => 'Skip';

  @override
  String get cook => 'Cook';

  @override
  String weekIsOver(String week) {
    return '$week is over. Choose a later week.';
  }

  @override
  String get saveGroceryListFailed =>
      'Could not save the grocery list. Please try again.';

  @override
  String get settings => 'Settings';

  @override
  String get language => 'Language';

  @override
  String get systemDefault => 'System default';

  @override
  String get changeLanguageFailed =>
      'Could not change the language. Please try again.';

  @override
  String get account => 'Account';

  @override
  String get notLoggedIn => 'Not logged in';

  @override
  String get logIn => 'Log in';

  @override
  String get logOut => 'Log out';

  @override
  String get createAccount => 'Create account';

  @override
  String get switchToCreateAccount => 'Create an account';

  @override
  String get switchToLogIn => 'I already have an account';

  @override
  String get emailLabel => 'Email';

  @override
  String get passwordLabel => 'Password';

  @override
  String get emailRequired => 'Email is required';

  @override
  String get passwordRequired => 'Password is required';

  @override
  String get invalidCredentials => 'Wrong email or password.';

  @override
  String get emailTaken => 'An account with this email already exists.';

  @override
  String get invalidEmail => 'Enter a valid email address.';

  @override
  String get passwordTooShort => 'The password must be at least 8 characters.';

  @override
  String get passwordTooLong => 'The password is too long.';

  @override
  String get serverUnreachable =>
      'Could not reach the server. Check your connection and try again.';

  @override
  String get somethingWentWrong => 'Something went wrong. Please try again.';

  @override
  String get logInLater => 'You can log in later in Settings.';

  @override
  String get unsyncedChangesWillBeLost =>
      'Some changes haven\'t been synced yet. If you log out now, they\'ll be lost.';

  @override
  String get logOutAnyway => 'Log out anyway';

  @override
  String get addToHomeScreen =>
      'To use Ambrogio offline and keep your data, add it to your Home Screen: tap Share, then \"Add to Home Screen\".';

  @override
  String get notNow => 'Not now';

  @override
  String get skipLogInTitle => 'Continue without an account?';

  @override
  String get skipLogInWarning =>
      'Without an account your recipes and lists are saved only on this device. You lose them by deleting the app or clearing the browser data, or if the browser removes them, and you can\'t use them on other devices. You can log in later in Settings to keep them safe.';

  @override
  String get backToLogIn => 'Back to log in';

  @override
  String get continueWithoutAccount => 'Continue without account';
}
