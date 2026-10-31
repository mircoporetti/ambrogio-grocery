import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_it.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('it'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Ambrogio Grocery'**
  String get appTitle;

  /// No description provided for @recipes.
  ///
  /// In en, this message translates to:
  /// **'Recipes'**
  String get recipes;

  /// No description provided for @noRecipesYet.
  ///
  /// In en, this message translates to:
  /// **'No recipes yet'**
  String get noRecipesYet;

  /// No description provided for @newRecipe.
  ///
  /// In en, this message translates to:
  /// **'New recipe'**
  String get newRecipe;

  /// No description provided for @editRecipe.
  ///
  /// In en, this message translates to:
  /// **'Edit recipe'**
  String get editRecipe;

  /// No description provided for @deleteRecipe.
  ///
  /// In en, this message translates to:
  /// **'Delete recipe'**
  String get deleteRecipe;

  /// No description provided for @recipeNoLongerExists.
  ///
  /// In en, this message translates to:
  /// **'This recipe no longer exists'**
  String get recipeNoLongerExists;

  /// No description provided for @photoOf.
  ///
  /// In en, this message translates to:
  /// **'Photo of {title}'**
  String photoOf(String title);

  /// No description provided for @portions.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 portion} other{{count} portions}}'**
  String portions(int count);

  /// No description provided for @ingredients.
  ///
  /// In en, this message translates to:
  /// **'Ingredients'**
  String get ingredients;

  /// No description provided for @procedure.
  ///
  /// In en, this message translates to:
  /// **'Procedure'**
  String get procedure;

  /// No description provided for @categories.
  ///
  /// In en, this message translates to:
  /// **'Categories'**
  String get categories;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @titleLabel.
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get titleLabel;

  /// No description provided for @titleRequired.
  ///
  /// In en, this message translates to:
  /// **'Title is required'**
  String get titleRequired;

  /// No description provided for @portionsLabel.
  ///
  /// In en, this message translates to:
  /// **'Portions'**
  String get portionsLabel;

  /// No description provided for @portionsInvalid.
  ///
  /// In en, this message translates to:
  /// **'Portions must be a whole number of at least 1'**
  String get portionsInvalid;

  /// No description provided for @ingredientLabel.
  ///
  /// In en, this message translates to:
  /// **'Ingredient'**
  String get ingredientLabel;

  /// No description provided for @ingredientNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Ingredient name is required'**
  String get ingredientNameRequired;

  /// No description provided for @quantityLabel.
  ///
  /// In en, this message translates to:
  /// **'Quantity'**
  String get quantityLabel;

  /// No description provided for @quantityInvalid.
  ///
  /// In en, this message translates to:
  /// **'Quantity must be a number greater than 0'**
  String get quantityInvalid;

  /// No description provided for @addIngredient.
  ///
  /// In en, this message translates to:
  /// **'Add ingredient'**
  String get addIngredient;

  /// No description provided for @addAtLeastOneIngredient.
  ///
  /// In en, this message translates to:
  /// **'Add at least one ingredient'**
  String get addAtLeastOneIngredient;

  /// No description provided for @procedureOptionalLabel.
  ///
  /// In en, this message translates to:
  /// **'Procedure (optional)'**
  String get procedureOptionalLabel;

  /// No description provided for @categoryLabel.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get categoryLabel;

  /// No description provided for @addCategory.
  ///
  /// In en, this message translates to:
  /// **'Add category'**
  String get addCategory;

  /// No description provided for @remove.
  ///
  /// In en, this message translates to:
  /// **'Remove {name}'**
  String remove(String name);

  /// No description provided for @addPhotoOptional.
  ///
  /// In en, this message translates to:
  /// **'Add photo (optional)'**
  String get addPhotoOptional;

  /// No description provided for @changePhoto.
  ///
  /// In en, this message translates to:
  /// **'Change photo'**
  String get changePhoto;

  /// No description provided for @saveRecipeFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not save the recipe. Please try again.'**
  String get saveRecipeFailed;

  /// No description provided for @deleteRecipeFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not delete the recipe. Please try again.'**
  String get deleteRecipeFailed;

  /// No description provided for @confirmDeleteRecipe.
  ///
  /// In en, this message translates to:
  /// **'Delete {title}?'**
  String confirmDeleteRecipe(String title);

  /// No description provided for @cannotBeUndone.
  ///
  /// In en, this message translates to:
  /// **'This cannot be undone.'**
  String get cannotBeUndone;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @groceryLists.
  ///
  /// In en, this message translates to:
  /// **'Grocery lists'**
  String get groceryLists;

  /// No description provided for @groceryList.
  ///
  /// In en, this message translates to:
  /// **'Grocery list'**
  String get groceryList;

  /// No description provided for @noGroceryListsYet.
  ///
  /// In en, this message translates to:
  /// **'No grocery lists yet'**
  String get noGroceryListsYet;

  /// No description provided for @deleteGroceryList.
  ///
  /// In en, this message translates to:
  /// **'Delete grocery list'**
  String get deleteGroceryList;

  /// No description provided for @confirmDeleteGroceryList.
  ///
  /// In en, this message translates to:
  /// **'Delete the list for {week}?'**
  String confirmDeleteGroceryList(String week);

  /// No description provided for @groceryListNoLongerExists.
  ///
  /// In en, this message translates to:
  /// **'This grocery list no longer exists'**
  String get groceryListNoLongerExists;

  /// No description provided for @updateGroceryListFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not update the grocery list. Please try again.'**
  String get updateGroceryListFailed;

  /// No description provided for @deleteGroceryListFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not delete the grocery list. Please try again.'**
  String get deleteGroceryListFailed;

  /// No description provided for @thisWeek.
  ///
  /// In en, this message translates to:
  /// **'This week'**
  String get thisWeek;

  /// No description provided for @recipeCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 recipe} other{{count} recipes}}'**
  String recipeCount(int count);

  /// No description provided for @planAWeek.
  ///
  /// In en, this message translates to:
  /// **'Plan a week'**
  String get planAWeek;

  /// No description provided for @planTheWeek.
  ///
  /// In en, this message translates to:
  /// **'Plan the week'**
  String get planTheWeek;

  /// No description provided for @earlierWeek.
  ///
  /// In en, this message translates to:
  /// **'Earlier week'**
  String get earlierWeek;

  /// No description provided for @laterWeek.
  ///
  /// In en, this message translates to:
  /// **'Later week'**
  String get laterWeek;

  /// No description provided for @confirmReplaceGroceryList.
  ///
  /// In en, this message translates to:
  /// **'Replace the list for {week}?'**
  String confirmReplaceGroceryList(String week);

  /// No description provided for @replaceGroceryListWarning.
  ///
  /// In en, this message translates to:
  /// **'The current list of that week will be lost.'**
  String get replaceGroceryListWarning;

  /// No description provided for @replace.
  ///
  /// In en, this message translates to:
  /// **'Replace'**
  String get replace;

  /// No description provided for @recipesChosen.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No recipes chosen yet} =1{1 recipe chosen} other{{count} recipes chosen}}'**
  String recipesChosen(int count);

  /// No description provided for @createGroceryList.
  ///
  /// In en, this message translates to:
  /// **'Create grocery list'**
  String get createGroceryList;

  /// No description provided for @addRecipesToPlan.
  ///
  /// In en, this message translates to:
  /// **'Add some recipes to plan your week'**
  String get addRecipesToPlan;

  /// No description provided for @seenAllRecipes.
  ///
  /// In en, this message translates to:
  /// **'You\'ve seen all your recipes'**
  String get seenAllRecipes;

  /// No description provided for @deckPosition.
  ///
  /// In en, this message translates to:
  /// **'{position} of {total}'**
  String deckPosition(int position, int total);

  /// No description provided for @skip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get skip;

  /// No description provided for @cook.
  ///
  /// In en, this message translates to:
  /// **'Cook'**
  String get cook;

  /// No description provided for @weekIsOver.
  ///
  /// In en, this message translates to:
  /// **'{week} is over. Choose a later week.'**
  String weekIsOver(String week);

  /// No description provided for @saveGroceryListFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not save the grocery list. Please try again.'**
  String get saveGroceryListFailed;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @systemDefault.
  ///
  /// In en, this message translates to:
  /// **'System default'**
  String get systemDefault;

  /// No description provided for @changeLanguageFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not change the language. Please try again.'**
  String get changeLanguageFailed;

  /// No description provided for @account.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get account;

  /// No description provided for @notLoggedIn.
  ///
  /// In en, this message translates to:
  /// **'Not logged in'**
  String get notLoggedIn;

  /// No description provided for @logIn.
  ///
  /// In en, this message translates to:
  /// **'Log in'**
  String get logIn;

  /// No description provided for @logOut.
  ///
  /// In en, this message translates to:
  /// **'Log out'**
  String get logOut;

  /// No description provided for @createAccount.
  ///
  /// In en, this message translates to:
  /// **'Create account'**
  String get createAccount;

  /// No description provided for @switchToCreateAccount.
  ///
  /// In en, this message translates to:
  /// **'Create an account'**
  String get switchToCreateAccount;

  /// No description provided for @switchToLogIn.
  ///
  /// In en, this message translates to:
  /// **'I already have an account'**
  String get switchToLogIn;

  /// No description provided for @emailLabel.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get emailLabel;

  /// No description provided for @passwordLabel.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get passwordLabel;

  /// No description provided for @emailRequired.
  ///
  /// In en, this message translates to:
  /// **'Email is required'**
  String get emailRequired;

  /// No description provided for @passwordRequired.
  ///
  /// In en, this message translates to:
  /// **'Password is required'**
  String get passwordRequired;

  /// No description provided for @invalidCredentials.
  ///
  /// In en, this message translates to:
  /// **'Wrong email or password.'**
  String get invalidCredentials;

  /// No description provided for @emailTaken.
  ///
  /// In en, this message translates to:
  /// **'An account with this email already exists.'**
  String get emailTaken;

  /// No description provided for @invalidEmail.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid email address.'**
  String get invalidEmail;

  /// No description provided for @passwordTooShort.
  ///
  /// In en, this message translates to:
  /// **'The password must be at least 8 characters.'**
  String get passwordTooShort;

  /// No description provided for @passwordTooLong.
  ///
  /// In en, this message translates to:
  /// **'The password is too long.'**
  String get passwordTooLong;

  /// No description provided for @serverUnreachable.
  ///
  /// In en, this message translates to:
  /// **'Could not reach the server. Check your connection and try again.'**
  String get serverUnreachable;

  /// No description provided for @somethingWentWrong.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong. Please try again.'**
  String get somethingWentWrong;

  /// No description provided for @logInLater.
  ///
  /// In en, this message translates to:
  /// **'You can log in later in Settings.'**
  String get logInLater;

  /// No description provided for @unsyncedChangesWillBeLost.
  ///
  /// In en, this message translates to:
  /// **'Some changes haven\'t been synced yet. If you log out now, they\'ll be lost.'**
  String get unsyncedChangesWillBeLost;

  /// No description provided for @logOutAnyway.
  ///
  /// In en, this message translates to:
  /// **'Log out anyway'**
  String get logOutAnyway;

  /// No description provided for @addToHomeScreen.
  ///
  /// In en, this message translates to:
  /// **'To use Ambrogio offline and keep your data, add it to your Home Screen: tap Share, then \"Add to Home Screen\".'**
  String get addToHomeScreen;

  /// No description provided for @notNow.
  ///
  /// In en, this message translates to:
  /// **'Not now'**
  String get notNow;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'it'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'it':
      return AppLocalizationsIt();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
