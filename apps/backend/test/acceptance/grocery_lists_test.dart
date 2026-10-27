import 'package:test/test.dart';

import 'support/accounts_api.dart';
import 'support/api_client.dart';
import 'support/fixed_clock_adapter.dart';
import 'support/grocery_lists_api.dart';

final t1 = DateTime.utc(2026, 10, 20, 9);
final t2 = t1.add(const Duration(minutes: 5));
final t3 = t2.add(const Duration(minutes: 5));

void main() {
  late AccountsApi accounts;
  late GroceryListsApi lists;
  late String ada;

  setUp(() async {
    final api = await ApiClient.start(clock: FixedClockAdapter());
    accounts = AccountsApi(api);
    lists = GroceryListsApi(api);
    ada = (await accounts.registerAndLogIn(
      'ada@example.com',
      'pw-ada-1',
    )).access;
  });

  Future<Map<String, Object?>> pulledList(String forWeek) async {
    final change = (await lists.pullChanges(
      ada,
    )).singleWhere((c) => c['week'] == forWeek);
    return change['list']! as Map<String, Object?>;
  }

  Future<Map<String, bool>> pulledTicks() async => {
    for (final i in (await pulledList(week))['items']! as List)
      (i as Map)['name'] as String: i['ticked'] as bool,
  };

  test('pushing and pulling needs a valid access token', () async {
    for (final token in [null, 'made-up-token']) {
      final push = await lists.push(token, [
        listChange(carbonaraList(), at: t1),
      ]);
      final pull = await lists.pull(token);

      for (final response in [push, pull]) {
        expect(response.status, 401, reason: '$token');
        expect(response['error'], 'unauthorized');
      }
    }
  });

  test('a pushed list comes back unchanged when pulling', () async {
    final change = listChange(
      carbonaraList(
        items: [
          item(guancialeId, 'Guanciale', ticked: true, tickedAt: t1),
          item(spaghettiId, 'Spaghetti'),
        ],
      ),
      at: t1,
    );

    final push = await lists.push(ada, [change]);

    expect(push.status, 204);
    expect(await lists.pullChanges(ada), [change]);
  });

  test('each account only sees and changes its own lists', () async {
    final bob = (await accounts.registerAndLogIn(
      'bob@example.com',
      'pw-bob-1',
    )).access;
    await lists.push(ada, [listChange(carbonaraList(), at: t1)]);

    expect(await lists.pullChanges(bob), isEmpty);

    await lists.push(bob, [listDeletion(at: t2)]);

    expect(await lists.pullChanges(ada), [listChange(carbonaraList(), at: t1)]);
  });

  test('there is one list per week', () async {
    await lists.push(ada, [
      listChange(carbonaraList(), at: t1),
      listChange(
        carbonaraList(id: otherListId),
        at: t1,
        forWeek: nextWeek,
      ),
    ]);

    final changes = await lists.pullChanges(ada);

    expect([for (final c in changes) c['week']], [week, nextWeek]);
  });

  group('when two phones plan the same week', () {
    test('the list planned last wins, whatever order they arrive in', () async {
      final later = listChange(carbonaraList(id: otherListId), at: t2);
      await lists.push(ada, [later]);
      await lists.push(ada, [listChange(carbonaraList(), at: t1)]);

      expect(await lists.pullChanges(ada), [later]);
    });

    test('a replaced list does not keep the ticks of the old one', () async {
      await lists.push(ada, [
        listChange(
          carbonaraList(
            items: [
              item(guancialeId, 'Guanciale', ticked: true, tickedAt: t1),
              item(spaghettiId, 'Spaghetti'),
            ],
          ),
          at: t1,
        ),
      ]);
      final replacement = listChange(
        carbonaraList(
          id: otherListId,
          items: [item('7e5f6a7b-8c9d-4e0f-8a1b-3c4d5e6f7a8b', 'Guanciale')],
        ),
        at: t2,
      );

      await lists.push(ada, [replacement]);

      expect(await lists.pullChanges(ada), [replacement]);
    });

    test('a deletion wins over older versions of the list', () async {
      await lists.push(ada, [listChange(carbonaraList(), at: t1)]);
      await lists.push(ada, [listDeletion(at: t2)]);
      await lists.push(ada, [listChange(carbonaraList(), at: t1)]);

      expect(await lists.pullChanges(ada), [listDeletion(at: t2)]);
    });

    test('a list planned after the deletion brings the week back', () async {
      await lists.push(ada, [listDeletion(at: t2)]);
      final planned = listChange(carbonaraList(id: otherListId), at: t3);
      await lists.push(ada, [planned]);

      expect(await lists.pullChanges(ada), [planned]);
    });
  });

  group('when two phones tick the same list', () {
    setUp(() => lists.push(ada, [listChange(carbonaraList(), at: t1)]));

    test('ticks on different items are both kept', () async {
      await lists.push(ada, [
        listChange(
          carbonaraList(
            items: [
              item(guancialeId, 'Guanciale', ticked: true, tickedAt: t2),
              item(spaghettiId, 'Spaghetti'),
            ],
          ),
          at: t1,
        ),
      ]);
      await lists.push(ada, [
        listChange(
          carbonaraList(
            items: [
              item(guancialeId, 'Guanciale'),
              item(spaghettiId, 'Spaghetti', ticked: true, tickedAt: t3),
            ],
          ),
          at: t1,
        ),
      ]);

      expect(await pulledTicks(), {'Guanciale': true, 'Spaghetti': true});
    });

    test('on the same item the latest tick wins', () async {
      List<Map<String, Object?>> guanciale(bool ticked, DateTime at) => [
        listChange(
          carbonaraList(
            items: [
              item(guancialeId, 'Guanciale', ticked: ticked, tickedAt: at),
              item(spaghettiId, 'Spaghetti'),
            ],
          ),
          at: t1,
        ),
      ];

      await lists.push(ada, guanciale(false, t3));
      await lists.push(ada, guanciale(true, t2));
      expect(await pulledTicks(), {'Guanciale': false, 'Spaghetti': false});

      await lists.push(ada, guanciale(true, t3.add(const Duration(days: 1))));
      expect(await pulledTicks(), {'Guanciale': true, 'Spaghetti': false});
    });
  });

  test('pushing the same changes again is harmless', () async {
    final changes = [
      listChange(carbonaraList(), at: t1),
      listChange(
        carbonaraList(id: otherListId),
        at: t1,
        forWeek: nextWeek,
      ),
    ];
    await lists.push(ada, changes);
    final cursor = (await lists.pull(ada))['cursor'] as String;

    final retry = await lists.push(ada, changes);

    expect(retry.status, 204);
    expect(await lists.pullChanges(ada), changes);
    expect((await lists.pull(ada, since: cursor))['changes'], isEmpty);
  });

  group('pulling from a cursor', () {
    test('gives only what changed since then, in its latest version', () async {
      await lists.push(ada, [
        listChange(carbonaraList(), at: t1),
        listChange(
          carbonaraList(id: otherListId),
          at: t1,
          forWeek: nextWeek,
        ),
      ]);
      final first = await lists.pull(ada);

      final ticked = listChange(
        carbonaraList(
          items: [
            item(guancialeId, 'Guanciale', ticked: true, tickedAt: t2),
            item(spaghettiId, 'Spaghetti'),
          ],
        ),
        at: t1,
      );
      await lists.push(ada, [ticked]);
      final second = await lists.pull(ada, since: first['cursor'] as String);

      expect(GroceryListsApi.changesOf(second), [ticked]);
      final third = await lists.pull(ada, since: second['cursor'] as String);
      expect(third['changes'], isEmpty);
    });

    test('goes page by page', () async {
      final weeks = [
        for (var i = 0; i < 5; i++)
          DateTime.utc(2026, 11, 2 + 7 * i).toIso8601String().substring(0, 10),
      ];
      await lists.push(ada, [
        for (final (i, w) in weeks.indexed)
          listChange(
            carbonaraList(id: '8f6a7b8c-9d0e-4f1a-9b2c-4d5e6f7a8b9$i'),
            at: t1,
            forWeek: w,
          ),
      ]);

      final pulled = <Object?>[];
      final hasMore = <bool>[];
      String? cursor;
      do {
        final page = await lists.pull(ada, since: cursor, limit: 2);
        pulled.addAll(GroceryListsApi.changesOf(page).map((c) => c['week']));
        cursor = page['cursor'] as String;
        hasMore.add(page['hasMore'] as bool);
      } while (hasMore.last);

      expect(pulled, weeks);
      expect(hasMore, [true, true, false]);
    });

    test('rejects a cursor or limit it did not make', () async {
      for (final query in [
        (since: 'abc', limit: null),
        (since: null, limit: 0),
        (since: null, limit: 1001),
      ]) {
        final response = await lists.pull(
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
    test('if a list breaks the grocery list rules', () async {
      final cases = <String, Map<String, Object?>>{
        'no recipes': listChange({...carbonaraList(), 'recipes': []}, at: t1),
        'no items': listChange({...carbonaraList(), 'items': []}, at: t1),
        'a blank item': listChange(
          carbonaraList(items: [item(guancialeId, '  ')]),
          at: t1,
        ),
        'no quantity': listChange(
          carbonaraList(
            items: [
              {...item(guancialeId, 'Salt'), 'quantity': 0.0},
            ],
          ),
          at: t1,
        ),
        'the same item twice': listChange(
          carbonaraList(
            items: [
              item(guancialeId, 'Guanciale'),
              item(guancialeId, 'Spaghetti'),
            ],
          ),
          at: t1,
        ),
        'a week not starting on Monday': listChange(
          carbonaraList(),
          at: t1,
          forWeek: '2026-10-20',
        ),
      };
      for (final MapEntry(key: reason, value: broken) in cases.entries) {
        final response = await lists.push(ada, [
          listChange(
            carbonaraList(id: otherListId),
            at: t1,
            forWeek: nextWeek,
          ),
          broken,
        ]);

        expect(response.status, 400, reason: reason);
        expect(response['error'], 'invalid_grocery_list', reason: reason);
      }
      expect(await lists.pullChanges(ada), isEmpty);
    });

    test('if it is not well formed', () async {
      for (final body in [
        'not json',
        '{}',
        '{"changes": [{"week": "next week", "updatedAt": '
            '"2026-10-20T09:00:00.000Z", "deleted": true}]}',
        '{"changes": [{"week": "$week", "updatedAt": '
            '"2026-10-20T09:00:00", "deleted": true}]}',
        '{"changes": [{"week": "$week", "updatedAt": '
            '"2026-10-20T09:00:00.000Z", "deleted": false}]}',
        '{"changes": [{"week": "$week", "updatedAt": '
            '"2026-10-20T09:00:00.000Z", "deleted": false, "list": '
            '{"id": "$listId", "recipes": ["Tea"], "items": [{"id": '
            '"$guancialeId", "name": "Tea", "quantity": 1, "unit": "cups", '
            '"ticked": false, "tickedAt": null}]}}]}',
      ]) {
        final response = await lists.pushRaw(ada, body);

        expect(response.status, 400, reason: body);
        expect(response['error'], 'invalid_request', reason: body);
      }
      expect(await lists.pullChanges(ada), isEmpty);
    });

    test('if it has more than 1000 changes', () async {
      final response = await lists.push(ada, [
        for (var i = 0; i < 1001; i++) listDeletion(at: t1),
      ]);

      expect(response.status, 413);
      expect(response['error'], 'too_many_changes');
    });
  });
}
