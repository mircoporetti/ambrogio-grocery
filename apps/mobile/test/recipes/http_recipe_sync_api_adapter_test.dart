import 'dart:convert';
import 'dart:io';

import 'package:ambrogio_grocery/account/domain/account_exceptions.dart';
import 'package:ambrogio_grocery/recipes/data/http_recipe_sync_api_adapter.dart';
import 'package:ambrogio_grocery/recipes/domain/ingredient.dart';
import 'package:ambrogio_grocery/recipes/domain/photo.dart';
import 'package:ambrogio_grocery/recipes/domain/photo_id.dart';
import 'package:ambrogio_grocery/recipes/domain/recipe.dart';
import 'package:ambrogio_grocery/recipes/domain/recipe_change.dart';
import 'package:ambrogio_grocery/recipes/domain/recipe_id.dart';
import 'package:ambrogio_grocery/recipes/domain/recipe_sync_exceptions.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

// The app's acceptance tests use a fake server, so this checks the one
// adapter they can't: the requests it sends and how it reads the answers.
void main() {
  final baseUrl = Uri.parse('http://api.test:8080');
  const recipeId = '0b9e4c1d-2f3a-4b5c-8d6e-7f8091a2b3c4';
  const photoId = '6f1c8a52-3c1e-4f0a-9d47-1a2b3c4d5e6f';
  final at = DateTime.utc(2026, 10, 20, 9);

  final recipeJson = {
    'title': 'Carbonara',
    'portions': 4,
    'procedure': 'Boil the pasta.',
    'photoId': photoId,
    'categories': ['Pasta'],
    'ingredients': [
      {'name': 'Spaghetti', 'quantity': 320.0, 'unit': 'g'},
    ],
  };

  http.Response json(int status, Object body) => http.Response(
    jsonEncode(body),
    status,
    headers: {'content-type': 'application/json'},
  );

  test('pushes the changes with the access token', () async {
    late http.Request sent;
    final api = HttpRecipeSyncApiAdapter(
      baseUrl,
      MockClient((request) async {
        sent = request;
        return http.Response('', 204);
      }),
    );

    await api.push('the-access', [
      RecipeChange(
        id: RecipeId(recipeId),
        updatedAt: at,
        recipe: Recipe(
          id: RecipeId(recipeId),
          title: 'Carbonara',
          portions: 4,
          procedure: 'Boil the pasta.',
          photo: Photo(id: PhotoId(photoId), path: '/docs/photos/c.jpg'),
          categories: ['Pasta'],
          ingredients: [
            Ingredient(
              name: 'Spaghetti',
              quantity: 320,
              unit: MeasureUnit.grams,
            ),
          ],
        ),
      ),
      RecipeChange(id: RecipeId(photoId), updatedAt: at),
    ]);

    expect(sent.method, 'POST');
    expect(sent.url.toString(), 'http://api.test:8080/recipes/changes');
    expect(sent.headers['authorization'], 'Bearer the-access');
    expect(jsonDecode(sent.body), {
      'changes': [
        {
          'id': recipeId,
          'updatedAt': '2026-10-20T09:00:00.000Z',
          'deleted': false,
          'recipe': recipeJson,
        },
        {
          'id': photoId,
          'updatedAt': '2026-10-20T09:00:00.000Z',
          'deleted': true,
        },
      ],
    });
  });

  test('pulls from the cursor and reads the changes', () async {
    late http.Request sent;
    final api = HttpRecipeSyncApiAdapter(
      baseUrl,
      MockClient((request) async {
        sent = request;
        return json(200, {
          'changes': [
            {
              'id': recipeId,
              'updatedAt': '2026-10-20T09:00:00.000Z',
              'deleted': false,
              'recipe': recipeJson,
            },
            {
              'id': photoId,
              'updatedAt': '2026-10-20T09:00:00.000Z',
              'deleted': true,
            },
          ],
          'cursor': '42',
          'hasMore': true,
        });
      }),
    );

    final page = await api.pull('the-access', since: '7');

    expect(sent.method, 'GET');
    expect(sent.url.toString(), 'http://api.test:8080/recipes/changes?since=7');
    expect(sent.headers['authorization'], 'Bearer the-access');
    expect((page.cursor, page.hasMore), ('42', true));
    final [edited, deleted] = page.changes;
    expect(edited.id.value, recipeId);
    expect(edited.updatedAt, at);
    expect(edited.recipe!.title, 'Carbonara');
    expect(edited.recipe!.photo!.id.value, photoId);
    expect(edited.recipe!.photo!.path, isNull);
    expect(edited.recipe!.ingredients, [
      Ingredient(name: 'Spaghetti', quantity: 320, unit: MeasureUnit.grams),
    ]);
    expect(deleted.deleted, isTrue);
  });

  test('a first pull sends no cursor', () async {
    late Uri url;
    final api = HttpRecipeSyncApiAdapter(
      baseUrl,
      MockClient((request) async {
        url = request.url;
        return json(200, {'changes': [], 'cursor': '0', 'hasMore': false});
      }),
    );

    await api.pull('the-access');

    expect(url.queryParameters, isEmpty);
  });

  test(
    'a rejected token, a failure and a broken answer are told apart',
    () async {
      final expected = {
        json(401, {'error': 'unauthorized'}):
            isA<AccessTokenRejectedException>(),
        json(500, {'error': 'x'}): isA<UnexpectedSyncResponseException>(),
        http.Response('not json', 200): isA<UnexpectedSyncResponseException>(),
        json(200, {'changes': 'nope'}): isA<UnexpectedSyncResponseException>(),
      };
      for (final MapEntry(key: response, value: matcher) in expected.entries) {
        final api = HttpRecipeSyncApiAdapter(
          baseUrl,
          MockClient((_) async => response),
        );

        await expectLater(
          api.pull('the-access'),
          throwsA(matcher),
          reason: response.body,
        );
      }
    },
  );

  test('a network failure means the server is unreachable', () async {
    final api = HttpRecipeSyncApiAdapter(
      baseUrl,
      MockClient((request) async {
        throw http.ClientException(
          const SocketException('Connection refused').toString(),
          request.url,
        );
      }),
    );

    await expectLater(
      api.push('the-access', []),
      throwsA(isA<SyncServerUnreachableException>()),
    );
  });
}
