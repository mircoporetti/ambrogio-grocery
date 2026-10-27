import 'dart:convert';

import 'package:ambrogio_api_contract/ambrogio_api_contract.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';

import '../../accounts/application/authenticate.dart';
import '../../accounts/domain/account_exceptions.dart';
import '../../http/json.dart';
import '../application/pull_recipe_changes.dart';
import '../application/push_recipe_changes.dart';
import '../domain/ingredient.dart';
import '../domain/photo_id.dart';
import '../domain/recipe.dart';
import '../domain/recipe_change.dart';
import '../domain/recipe_exceptions.dart';
import '../domain/recipe_id.dart';

class RecipeRoutes {
  RecipeRoutes(this._authenticate, this._push, this._pull);

  final Authenticate _authenticate;
  final PushRecipeChanges _push;
  final PullRecipeChanges _pull;

  Router get router => Router()
    ..post(recipeChangesPath, _guard(_pushChanges))
    ..get(recipeChangesPath, _guard(_pullChanges));

  Future<Response> _pushChanges(Request request) async {
    final account = _authenticate(bearerToken(request));
    final body = PushRecipeChangesRequest.fromJson(
      jsonDecode(await request.readAsString()),
    );
    await _push(account, body.changes.map(_toChange).toList());
    return Response(204);
  }

  Future<Response> _pullChanges(Request request) async {
    final account = _authenticate(bearerToken(request));
    final query = PullRecipeChangesRequest.fromQuery(
      request.url.queryParameters,
    );
    final after = switch (query.since) {
      null => 0,
      final since => int.tryParse(since) ?? -1,
    };
    final limit = query.limit ?? PullRecipeChanges.defaultLimit;
    if (after < 0 || limit < 1 || limit > PullRecipeChanges.maxLimit) {
      throw const InvalidRequestException();
    }
    final page = await _pull(account, after: after, limit: limit);
    return jsonResponse(
      200,
      PullRecipeChangesResponse(
        changes: page.changes.map(_toBody).toList(),
        cursor: '${page.cursor}',
        hasMore: page.hasMore,
      ).toJson(),
    );
  }

  RecipeChange _toChange(RecipeChangeBody body) => RecipeChange(
    id: _parse(RecipeId.new, body.id),
    updatedAt: body.updatedAt,
    recipe: switch (body.recipe) {
      null => null,
      final recipe => Recipe(
        title: recipe.title,
        portions: recipe.portions,
        procedure: recipe.procedure,
        photoId: switch (recipe.photoId) {
          null => null,
          final id => _parse(PhotoId.new, id),
        },
        categories: recipe.categories,
        ingredients: [
          for (final i in recipe.ingredients)
            Ingredient(
              name: i.name,
              quantity: i.quantity,
              unit:
                  MeasureUnit.fromSymbol(i.unit) ??
                  (throw const InvalidRequestException()),
            ),
        ],
      ),
    },
  );

  RecipeChangeBody _toBody(RecipeChange change) => RecipeChangeBody(
    id: change.id.value,
    updatedAt: change.updatedAt,
    recipe: switch (change.recipe) {
      null => null,
      final recipe => RecipeBody(
        title: recipe.title,
        portions: recipe.portions,
        procedure: recipe.procedure,
        photoId: recipe.photoId?.value,
        categories: recipe.categories,
        ingredients: [
          for (final i in recipe.ingredients)
            IngredientBody(
              name: i.name,
              quantity: i.quantity,
              unit: i.unit.symbol,
            ),
        ],
      ),
    },
  );

  T _parse<T>(T Function(String) create, String value) {
    try {
      return create(value);
    } on ArgumentError {
      throw const InvalidRequestException();
    }
  }

  Handler _guard(Handler handler) => (request) async {
    try {
      return await handler(request);
    } on FormatException {
      return errorResponse(400, ErrorCodes.invalidRequest);
    } on InvalidRequestException {
      return errorResponse(400, ErrorCodes.invalidRequest);
    } on NotAuthenticatedException {
      return errorResponse(
        401,
        ErrorCodes.unauthorized,
        headers: {'www-authenticate': 'Bearer'},
      );
    } on RecipeException catch (e) {
      return switch (e) {
        InvalidRecipeException() => errorResponse(
          400,
          ErrorCodes.invalidRecipe,
        ),
        TooManyChangesException() => errorResponse(
          413,
          ErrorCodes.tooManyChanges,
        ),
      };
    }
  };
}
