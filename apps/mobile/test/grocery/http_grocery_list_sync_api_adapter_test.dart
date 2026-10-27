import 'dart:convert';
import 'dart:io';

import 'package:ambrogio_grocery/account/domain/account_exceptions.dart';
import 'package:ambrogio_grocery/grocery/data/http_grocery_list_sync_api_adapter.dart';
import 'package:ambrogio_grocery/grocery/domain/grocery_item.dart';
import 'package:ambrogio_grocery/grocery/domain/grocery_item_id.dart';
import 'package:ambrogio_grocery/grocery/domain/grocery_list.dart';
import 'package:ambrogio_grocery/grocery/domain/grocery_list_change.dart';
import 'package:ambrogio_grocery/grocery/domain/grocery_list_id.dart';
import 'package:ambrogio_grocery/grocery/domain/grocery_list_sync_exceptions.dart';
import 'package:ambrogio_grocery/grocery/domain/week.dart';
import 'package:ambrogio_grocery/recipes/domain/ingredient.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

// The app's acceptance tests use a fake server, so this checks the one
// adapter they can't: the requests it sends and how it reads the answers.
void main() {
  final baseUrl = Uri.parse('http://api.test:8080');
  const listId = '3a1b2c3d-4e5f-4a6b-8c7d-9e0f1a2b3c4d';
  const itemId = '5c3d4e5f-6a7b-4c8d-8e9f-1a2b3c4d5e6f';
  final week = Week.fromKey('2026-10-19');
  final planned = DateTime.utc(2026, 10, 20, 9);
  final ticked = DateTime.utc(2026, 10, 21, 18, 30);

  final changeJson = {
    'week': '2026-10-19',
    'updatedAt': '2026-10-20T09:00:00.000Z',
    'deleted': false,
    'list': {
      'id': listId,
      'recipes': ['Carbonara'],
      'items': [
        {
          'id': itemId,
          'name': 'Guanciale',
          'quantity': 150.0,
          'unit': 'g',
          'ticked': true,
          'tickedAt': '2026-10-21T18:30:00.000Z',
        },
      ],
    },
  };

  http.Response json(int status, Object body) => http.Response(
    jsonEncode(body),
    status,
    headers: {'content-type': 'application/json'},
  );

  test('pushes the weeks with the access token', () async {
    late http.Request sent;
    final api = HttpGroceryListSyncApiAdapter(
      baseUrl,
      MockClient((request) async {
        sent = request;
        return http.Response('', 204);
      }),
    );

    await api.push('the-access', [
      GroceryListChange(
        week: week,
        updatedAt: planned,
        list: GroceryList(
          id: GroceryListId(listId),
          week: week,
          recipes: ['Carbonara'],
          items: [
            GroceryItem(
              Ingredient(
                name: 'Guanciale',
                quantity: 150,
                unit: MeasureUnit.grams,
              ),
              id: GroceryItemId(itemId),
              ticked: true,
              tickedAt: ticked,
            ),
          ],
        ),
      ),
      GroceryListChange(week: week.next, updatedAt: planned),
    ]);

    expect(sent.method, 'POST');
    expect(sent.url.toString(), 'http://api.test:8080/grocery-lists/changes');
    expect(sent.headers['authorization'], 'Bearer the-access');
    expect(jsonDecode(sent.body), {
      'changes': [
        changeJson,
        {
          'week': '2026-10-26',
          'updatedAt': '2026-10-20T09:00:00.000Z',
          'deleted': true,
        },
      ],
    });
  });

  test('pulls from the cursor and reads the weeks', () async {
    late Uri url;
    final api = HttpGroceryListSyncApiAdapter(
      baseUrl,
      MockClient((request) async {
        url = request.url;
        return json(200, {
          'changes': [changeJson],
          'cursor': '42',
          'hasMore': false,
        });
      }),
    );

    final page = await api.pull('the-access', since: '7');

    expect(url.queryParameters, {'since': '7'});
    expect((page.cursor, page.hasMore), ('42', false));
    final change = page.changes.single;
    expect(change.week, week);
    expect(change.updatedAt, planned);
    final item = change.list!.items.single;
    expect(item.id, GroceryItemId(itemId));
    expect(item.ingredient.name, 'Guanciale');
    expect((item.ticked, item.tickedAt), (true, ticked));
  });

  test(
    'a rejected token, a failure and a broken answer are told apart',
    () async {
      final expected = {
        json(401, {'error': 'unauthorized'}):
            isA<AccessTokenRejectedException>(),
        json(500, {'error': 'x'}):
            isA<UnexpectedGroceryListResponseException>(),
        http.Response('not json', 200):
            isA<UnexpectedGroceryListResponseException>(),
        json(200, {
          'changes': [
            {...changeJson, 'week': '2026-10-20'},
          ],
          'cursor': '1',
          'hasMore': false,
        }): isA<UnexpectedGroceryListResponseException>(),
      };
      for (final MapEntry(key: response, value: matcher) in expected.entries) {
        final api = HttpGroceryListSyncApiAdapter(
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
    final api = HttpGroceryListSyncApiAdapter(
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
      throwsA(isA<GroceryListServerUnreachableException>()),
    );
  });
}
