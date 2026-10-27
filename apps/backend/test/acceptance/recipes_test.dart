import 'package:test/test.dart';

import 'support/accounts_api.dart';
import 'support/api_client.dart';
import 'support/fixed_clock_adapter.dart';
import 'support/recipes_api.dart';

const pastaId = '0b9e4c1d-2f3a-4b5c-8d6e-7f8091a2b3c4';
const saladId = '1c0f5d2e-3a4b-4c5d-9e6f-8091a2b3c4d5';

final t1 = DateTime.utc(2026, 10, 20, 9);
final t2 = t1.add(const Duration(minutes: 5));
final t3 = t2.add(const Duration(minutes: 5));

void main() {
  late AccountsApi accounts;
  late RecipesApi recipes;
  late String ada;

  setUp(() async {
    final api = await ApiClient.start(clock: FixedClockAdapter());
    accounts = AccountsApi(api);
    recipes = RecipesApi(api);
    ada = (await accounts.registerAndLogIn(
      'ada@example.com',
      'pw-ada-1',
    )).access;
  });

  test('pushing and pulling needs a valid access token', () async {
    for (final token in [null, 'made-up-token']) {
      final push = await recipes.push(token, [upsert(pastaId, pasta, at: t1)]);
      final pull = await recipes.pull(token);

      for (final response in [push, pull]) {
        expect(response.status, 401, reason: '$token');
        expect(response['error'], 'unauthorized');
      }
    }
  });

  test('a pushed recipe comes back unchanged when pulling', () async {
    final push = await recipes.push(ada, [upsert(pastaId, pasta, at: t1)]);

    expect(push.status, 204);
    expect(await recipes.pullChanges(ada), [upsert(pastaId, pasta, at: t1)]);
  });

  test('a new account starts with no recipes', () async {
    final response = await recipes.pull(ada);

    expect(response.status, 200);
    expect(response['changes'], isEmpty);
    expect(response['hasMore'], false);
    expect(response['cursor'], isA<String>());
  });

  test('each account only sees and changes its own recipes', () async {
    final bob = (await accounts.registerAndLogIn(
      'bob@example.com',
      'pw-bob-1',
    )).access;
    await recipes.push(ada, [upsert(pastaId, pasta, at: t1)]);

    expect(await recipes.pullChanges(bob), isEmpty);

    await recipes.push(bob, [upsert(pastaId, salad, at: t2)]);
    await recipes.push(bob, [deletion(pastaId, at: t3)]);

    expect(await recipes.pullChanges(ada), [upsert(pastaId, pasta, at: t1)]);
  });

  group('when two devices change the same recipe', () {
    test('the latest change wins, whatever order they arrive in', () async {
      await recipes.push(ada, [upsert(pastaId, salad, at: t2)]);
      await recipes.push(ada, [upsert(pastaId, pasta, at: t1)]);

      expect(await recipes.pullChanges(ada), [upsert(pastaId, salad, at: t2)]);
    });

    test('a deletion wins over older edits', () async {
      await recipes.push(ada, [upsert(pastaId, pasta, at: t1)]);
      await recipes.push(ada, [deletion(pastaId, at: t2)]);
      await recipes.push(ada, [upsert(pastaId, salad, at: t1)]);

      expect(await recipes.pullChanges(ada), [deletion(pastaId, at: t2)]);
    });

    test('an edit made after the deletion brings the recipe back', () async {
      await recipes.push(ada, [deletion(pastaId, at: t2)]);
      await recipes.push(ada, [upsert(pastaId, salad, at: t3)]);

      expect(await recipes.pullChanges(ada), [upsert(pastaId, salad, at: t3)]);
    });
  });

  test('pushing the same changes again is harmless', () async {
    final changes = [
      upsert(pastaId, pasta, at: t1),
      upsert(saladId, salad, at: t1),
    ];
    await recipes.push(ada, changes);
    final cursor = (await recipes.pull(ada))['cursor'] as String;

    final retry = await recipes.push(ada, changes);

    expect(retry.status, 204);
    expect(await recipes.pullChanges(ada), changes);
    expect((await recipes.pull(ada, since: cursor))['changes'], isEmpty);
  });

  test('later changes in the same push win over earlier ones', () async {
    await recipes.push(ada, [
      upsert(pastaId, pasta, at: t1),
      upsert(pastaId, salad, at: t2),
    ]);

    expect(await recipes.pullChanges(ada), [upsert(pastaId, salad, at: t2)]);
  });

  group('pulling from a cursor', () {
    test('gives only what changed since then', () async {
      await recipes.push(ada, [upsert(pastaId, pasta, at: t1)]);
      final first = await recipes.pull(ada);

      await recipes.push(ada, [upsert(saladId, salad, at: t2)]);
      final second = await recipes.pull(ada, since: first['cursor'] as String);

      expect(RecipesApi.changesOf(second), [upsert(saladId, salad, at: t2)]);

      final third = await recipes.pull(ada, since: second['cursor'] as String);
      expect(third['changes'], isEmpty);
      expect(third['cursor'], second['cursor']);
    });

    test('gives a changed recipe again, in its latest version', () async {
      await recipes.push(ada, [
        upsert(pastaId, pasta, at: t1),
        upsert(saladId, salad, at: t1),
      ]);
      final first = await recipes.pull(ada);

      await recipes.push(ada, [deletion(pastaId, at: t2)]);
      final second = await recipes.pull(ada, since: first['cursor'] as String);

      expect(RecipesApi.changesOf(second), [deletion(pastaId, at: t2)]);
    });

    test('goes page by page', () async {
      final ids = [
        for (var i = 0; i < 5; i++) '2d1a6e3f-4b5c-4d6e-8f70-81a2b3c4d5e$i',
      ];
      await recipes.push(ada, [
        for (final id in ids) upsert(id, salad, at: t1),
      ]);

      final pulled = <Object?>[];
      String? cursor;
      final pages = <bool>[];
      do {
        final page = await recipes.pull(ada, since: cursor, limit: 2);
        pulled.addAll(RecipesApi.changesOf(page).map((c) => c['id']));
        cursor = page['cursor'] as String;
        pages.add(page['hasMore'] as bool);
      } while (pages.last);

      expect(pulled, ids);
      expect(pages, [true, true, false]);
    });

    test('rejects a cursor or limit it did not make', () async {
      for (final query in [
        (since: 'abc', limit: null),
        (since: '-1', limit: null),
        (since: null, limit: 0),
        (since: null, limit: 1001),
      ]) {
        final response = await recipes.pull(
          ada,
          since: query.since,
          limit: query.limit,
        );

        expect(response.status, 400, reason: '$query');
        expect(response['error'], 'invalid_request');
      }
    });
  });

  group('a push is rejected as a whole', () {
    test('if a recipe breaks the recipe rules', () async {
      for (final broken in <Map<String, Object?>>[
        {...pasta, 'title': '  '},
        {...pasta, 'portions': 0},
        {...pasta, 'ingredients': <Object?>[]},
        {
          ...pasta,
          'ingredients': [
            {'name': ' ', 'quantity': 1.0, 'unit': 'g'},
          ],
        },
        {
          ...pasta,
          'ingredients': [
            {'name': 'Salt', 'quantity': 0.0, 'unit': 'g'},
          ],
        },
      ]) {
        final response = await recipes.push(ada, [
          upsert(saladId, salad, at: t1),
          upsert(pastaId, broken, at: t1),
        ]);

        expect(response.status, 400, reason: '$broken');
        expect(response['error'], 'invalid_recipe', reason: '$broken');
      }
      expect(await recipes.pullChanges(ada), isEmpty);
    });

    test('if it is not well formed', () async {
      for (final body in [
        'not json',
        '[]',
        '{}',
        '{"changes": [{"id": "not-a-uuid", "updatedAt": '
            '"2026-10-20T09:00:00.000Z", "deleted": true}]}',
        '{"changes": [{"id": "$pastaId", "updatedAt": "yesterday", '
            '"deleted": true}]}',
        '{"changes": [{"id": "$pastaId", "updatedAt": '
            '"2026-10-20T09:00:00.000Z", "deleted": false}]}',
        '{"changes": [{"id": "$pastaId", "updatedAt": '
            '"2026-10-20T09:00:00.000Z", "deleted": false, "recipe": '
            '{"title": "Tea", "portions": 1, "categories": [], '
            '"ingredients": [{"name": "Tea", "quantity": 1, "unit": "cups"}]}}]}',
      ]) {
        final response = await recipes.pushRaw(ada, body);

        expect(response.status, 400, reason: body);
        expect(response['error'], 'invalid_request', reason: body);
      }
      expect(await recipes.pullChanges(ada), isEmpty);
    });

    test('if it has more than 1000 changes', () async {
      final response = await recipes.push(ada, [
        for (var i = 0; i < 1001; i++) deletion(pastaId, at: t1),
      ]);

      expect(response.status, 413);
      expect(response['error'], 'too_many_changes');
    });
  });

  test('categories are kept once each, in their order', () async {
    await recipes.push(ada, [
      upsert(pastaId, {
        ...pasta,
        'categories': [' Quick', 'quick', 'Dinner ', ''],
      }, at: t1),
    ]);

    final [change] = await recipes.pullChanges(ada);
    expect((change['recipe']! as Map)['categories'], ['Quick', 'Dinner']);
  });
}
