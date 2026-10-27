import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:ambrogio_api_contract/ambrogio_api_contract.dart';
import 'package:http/http.dart' as http;

import '../../account/domain/account_exceptions.dart';
import '../domain/ingredient.dart';
import '../domain/photo.dart';
import '../domain/photo_id.dart';
import '../domain/recipe.dart';
import '../domain/recipe_change.dart';
import '../domain/recipe_id.dart';
import '../domain/recipe_sync_api_port.dart';
import '../domain/recipe_sync_exceptions.dart';

class HttpRecipeSyncApiAdapter implements RecipeSyncApiPort {
  HttpRecipeSyncApiAdapter(this._baseUrl, this._client);

  final Uri _baseUrl;
  final http.Client _client;

  static const _timeout = Duration(seconds: 30);

  @override
  Future<void> push(String accessToken, List<RecipeChange> changes) async {
    final request = http.Request('POST', _baseUrl.resolve(recipeChangesPath))
      ..headers['content-type'] = 'application/json'
      ..body = jsonEncode(
        PushRecipeChangesRequest(changes.map(_toBody).toList()).toJson(),
      );
    await _send(request, accessToken);
  }

  @override
  Future<RecipeChangesPage> pull(String accessToken, {String? since}) async {
    final url = _baseUrl
        .resolve(recipeChangesPath)
        .replace(queryParameters: PullChangesRequest(since: since).toQuery());
    final body = await _send(http.Request('GET', url), accessToken);
    try {
      final response = PullRecipeChangesResponse.fromJson(jsonDecode(body));
      return RecipeChangesPage(
        changes: response.changes.map(_toChange).toList(),
        cursor: response.cursor,
        hasMore: response.hasMore,
      );
    } on FormatException {
      throw const UnexpectedSyncResponseException();
    } on ArgumentError {
      throw const UnexpectedSyncResponseException();
    }
  }

  Future<String> _send(http.Request request, String accessToken) async {
    request.headers
      ..['accept'] = 'application/json'
      ..['authorization'] = 'Bearer $accessToken';
    final http.Response response;
    try {
      response = await http.Response.fromStream(
        await _client.send(request),
      ).timeout(_timeout);
    } on http.ClientException {
      throw const SyncServerUnreachableException();
    } on SocketException {
      throw const SyncServerUnreachableException();
    } on TimeoutException {
      throw const SyncServerUnreachableException();
    }
    final status = response.statusCode;
    if (status >= 200 && status < 300) return response.body;
    if (status == 401) throw const AccessTokenRejectedException();
    throw const UnexpectedSyncResponseException();
  }

  RecipeChangeBody _toBody(RecipeChange change) => RecipeChangeBody(
    id: change.id.value,
    updatedAt: change.updatedAt,
    recipe: switch (change.recipe) {
      null => null,
      final recipe => RecipeBody(
        title: recipe.title,
        portions: recipe.portions,
        procedure: recipe.procedure,
        photoId: recipe.photo?.id.value,
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

  RecipeChange _toChange(RecipeChangeBody body) => RecipeChange(
    id: RecipeId(body.id),
    updatedAt: body.updatedAt,
    recipe: switch (body.recipe) {
      null => null,
      final recipe => Recipe(
        id: RecipeId(body.id),
        title: recipe.title,
        portions: recipe.portions,
        procedure: recipe.procedure,
        photo: switch (recipe.photoId) {
          null => null,
          final id => Photo(id: PhotoId(id)),
        },
        categories: recipe.categories,
        ingredients: [
          for (final i in recipe.ingredients)
            Ingredient(
              name: i.name,
              quantity: i.quantity,
              unit: MeasureUnit.values.firstWhere(
                (unit) => unit.symbol == i.unit,
                orElse: () => throw const FormatException('Unknown unit'),
              ),
            ),
        ],
      ),
    },
  );
}
