import 'package:ambrogio_grocery/account/domain/account_exceptions.dart';
import 'package:ambrogio_grocery/recipes/domain/ingredient.dart';
import 'package:ambrogio_grocery/recipes/domain/recipe.dart';
import 'package:ambrogio_grocery/recipes/domain/recipe_change.dart';
import 'package:ambrogio_grocery/recipes/domain/recipe_id.dart';
import 'package:ambrogio_grocery/recipes/domain/recipe_sync_api_port.dart';
import 'package:ambrogio_grocery/recipes/domain/recipe_sync_exceptions.dart';

import 'fake_account_api_adapter.dart';

class FakeRecipeSyncApiAdapter implements RecipeSyncApiPort {
  FakeRecipeSyncApiAdapter(this._accounts);

  final FakeAccountApiAdapter _accounts;
  final _stored = <String, Map<RecipeId, ({RecipeChange change, int at})>>{};
  var _cursor = 0;
  bool unreachable = false;

  void givenRecipe(String email, String title, {RecipeId? id}) {
    final recipeId = id ?? RecipeId.generate();
    _store(
      email,
      RecipeChange(
        id: recipeId,
        updatedAt: DateTime.now(),
        recipe: Recipe(
          id: recipeId,
          title: title,
          portions: 2,
          ingredients: [
            Ingredient(name: 'Rice', quantity: 300, unit: MeasureUnit.grams),
          ],
        ),
      ),
    );
  }

  List<Recipe> recipesOf(String email) => [
    for (final entry in _ordered(email)) ?entry.change.recipe,
  ];

  @override
  Future<void> push(String accessToken, List<RecipeChange> changes) async {
    final email = _authenticate(accessToken);
    for (final change in changes) {
      _store(email, change);
    }
  }

  @override
  Future<RecipeChangesPage> pull(String accessToken, {String? since}) async {
    final email = _authenticate(accessToken);
    final after = int.parse(since ?? '0');
    final changes = _ordered(email).where((e) => e.at > after).toList();
    return RecipeChangesPage(
      changes: [for (final e in changes) e.change],
      cursor: '${changes.isEmpty ? after : changes.last.at}',
      hasMore: false,
    );
  }

  void _store(String email, RecipeChange change) {
    final recipes = _stored.putIfAbsent(email, () => {});
    final current = recipes[change.id];
    if (current != null &&
        !change.updatedAt.isAfter(current.change.updatedAt)) {
      return;
    }
    recipes[change.id] = (change: change, at: ++_cursor);
  }

  List<({RecipeChange change, int at})> _ordered(String email) =>
      (_stored[email]?.values.toList() ?? [])
        ..sort((a, b) => a.at.compareTo(b.at));

  String _authenticate(String accessToken) {
    if (unreachable) throw const SyncServerUnreachableException();
    return _accounts.emailFor(accessToken) ??
        (throw const AccessTokenRejectedException());
  }
}
