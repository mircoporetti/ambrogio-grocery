// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Italian (`it`).
class AppLocalizationsIt extends AppLocalizations {
  AppLocalizationsIt([String locale = 'it']) : super(locale);

  @override
  String get appTitle => 'Ambrogio Grocery';

  @override
  String get recipes => 'Ricette';

  @override
  String get noRecipesYet => 'Ancora nessuna ricetta';

  @override
  String get newRecipe => 'Nuova ricetta';

  @override
  String get editRecipe => 'Modifica ricetta';

  @override
  String get deleteRecipe => 'Elimina ricetta';

  @override
  String get recipeNoLongerExists => 'Questa ricetta non esiste più';

  @override
  String photoOf(String title) {
    return 'Foto di $title';
  }

  @override
  String portions(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count porzioni',
      one: '1 porzione',
    );
    return '$_temp0';
  }

  @override
  String get ingredients => 'Ingredienti';

  @override
  String get procedure => 'Procedimento';

  @override
  String get categories => 'Categorie';

  @override
  String get save => 'Salva';

  @override
  String get titleLabel => 'Titolo';

  @override
  String get titleRequired => 'Il titolo è obbligatorio';

  @override
  String get portionsLabel => 'Porzioni';

  @override
  String get portionsInvalid =>
      'Le porzioni devono essere un numero intero di almeno 1';

  @override
  String get ingredientLabel => 'Ingrediente';

  @override
  String get ingredientNameRequired =>
      'Il nome dell\'ingrediente è obbligatorio';

  @override
  String get quantityLabel => 'Quantità';

  @override
  String get quantityInvalid =>
      'La quantità deve essere un numero maggiore di 0';

  @override
  String get addIngredient => 'Aggiungi ingrediente';

  @override
  String get addAtLeastOneIngredient => 'Aggiungi almeno un ingrediente';

  @override
  String get procedureOptionalLabel => 'Procedimento (facoltativo)';

  @override
  String get categoryLabel => 'Categoria';

  @override
  String get addCategory => 'Aggiungi categoria';

  @override
  String remove(String name) {
    return 'Rimuovi $name';
  }

  @override
  String get addPhotoOptional => 'Aggiungi foto (facoltativa)';

  @override
  String get changePhoto => 'Cambia foto';

  @override
  String get saveRecipeFailed => 'Impossibile salvare la ricetta. Riprova.';

  @override
  String get deleteRecipeFailed => 'Impossibile eliminare la ricetta. Riprova.';

  @override
  String confirmDeleteRecipe(String title) {
    return 'Eliminare $title?';
  }

  @override
  String get cannotBeUndone => 'Questa azione non può essere annullata.';

  @override
  String get cancel => 'Annulla';

  @override
  String get delete => 'Elimina';

  @override
  String get groceryLists => 'Liste della spesa';

  @override
  String get groceryList => 'Lista della spesa';

  @override
  String get noGroceryListsYet => 'Ancora nessuna lista della spesa';

  @override
  String get deleteGroceryList => 'Elimina lista della spesa';

  @override
  String confirmDeleteGroceryList(String week) {
    return 'Eliminare la lista della settimana $week?';
  }

  @override
  String get groceryListNoLongerExists =>
      'Questa lista della spesa non esiste più';

  @override
  String get updateGroceryListFailed =>
      'Impossibile aggiornare la lista della spesa. Riprova.';

  @override
  String get deleteGroceryListFailed =>
      'Impossibile eliminare la lista della spesa. Riprova.';

  @override
  String get thisWeek => 'Questa settimana';

  @override
  String recipeCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ricette',
      one: '1 ricetta',
    );
    return '$_temp0';
  }

  @override
  String get planAWeek => 'Pianifica una settimana';

  @override
  String get planTheWeek => 'Pianifica la settimana';

  @override
  String get earlierWeek => 'Settimana precedente';

  @override
  String get laterWeek => 'Settimana successiva';

  @override
  String confirmReplaceGroceryList(String week) {
    return 'Sostituire la lista della settimana $week?';
  }

  @override
  String get replaceGroceryListWarning =>
      'La lista attuale di quella settimana andrà persa.';

  @override
  String get replace => 'Sostituisci';

  @override
  String recipesChosen(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ricette scelte',
      one: '1 ricetta scelta',
      zero: 'Nessuna ricetta scelta',
    );
    return '$_temp0';
  }

  @override
  String get createGroceryList => 'Crea la lista della spesa';

  @override
  String get addRecipesToPlan =>
      'Aggiungi qualche ricetta per pianificare la settimana';

  @override
  String get seenAllRecipes => 'Hai visto tutte le tue ricette';

  @override
  String deckPosition(int position, int total) {
    return '$position di $total';
  }

  @override
  String get skip => 'Salta';

  @override
  String get cook => 'Cucina';

  @override
  String weekIsOver(String week) {
    return 'La settimana $week è finita. Scegli una settimana successiva.';
  }

  @override
  String get saveGroceryListFailed =>
      'Impossibile salvare la lista della spesa. Riprova.';

  @override
  String get settings => 'Impostazioni';

  @override
  String get language => 'Lingua';

  @override
  String get systemDefault => 'Predefinita di sistema';

  @override
  String get changeLanguageFailed => 'Impossibile cambiare la lingua. Riprova.';

  @override
  String get account => 'Account';

  @override
  String get notLoggedIn => 'Accesso non effettuato';

  @override
  String get logIn => 'Accedi';

  @override
  String get logOut => 'Esci';

  @override
  String get createAccount => 'Crea account';

  @override
  String get switchToCreateAccount => 'Crea un account';

  @override
  String get switchToLogIn => 'Ho già un account';

  @override
  String get emailLabel => 'Email';

  @override
  String get passwordLabel => 'Password';

  @override
  String get emailRequired => 'L\'email è obbligatoria';

  @override
  String get passwordRequired => 'La password è obbligatoria';

  @override
  String get invalidCredentials => 'Email o password errate.';

  @override
  String get emailTaken => 'Esiste già un account con questa email.';

  @override
  String get invalidEmail => 'Inserisci un indirizzo email valido.';

  @override
  String get passwordTooShort => 'La password deve avere almeno 8 caratteri.';

  @override
  String get passwordTooLong => 'La password è troppo lunga.';

  @override
  String get serverUnreachable =>
      'Impossibile raggiungere il server. Controlla la connessione e riprova.';

  @override
  String get somethingWentWrong => 'Qualcosa è andato storto. Riprova.';

  @override
  String get logInLater => 'Puoi accedere più tardi dalle Impostazioni.';

  @override
  String get unsyncedChangesWillBeLost =>
      'Alcune modifiche non sono ancora state sincronizzate. Se esci ora andranno perse.';

  @override
  String get logOutAnyway => 'Esci comunque';
}
