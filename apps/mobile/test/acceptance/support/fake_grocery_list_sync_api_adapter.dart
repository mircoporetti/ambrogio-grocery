import 'package:ambrogio_grocery/account/domain/account_exceptions.dart';
import 'package:ambrogio_grocery/grocery/domain/grocery_item.dart';
import 'package:ambrogio_grocery/grocery/domain/grocery_list.dart';
import 'package:ambrogio_grocery/grocery/domain/grocery_list_change.dart';
import 'package:ambrogio_grocery/grocery/domain/grocery_list_sync_api_port.dart';
import 'package:ambrogio_grocery/grocery/domain/grocery_list_sync_exceptions.dart';
import 'package:ambrogio_grocery/grocery/domain/week.dart';

import 'fake_account_api_adapter.dart';

class FakeGroceryListSyncApiAdapter implements GroceryListSyncApiPort {
  FakeGroceryListSyncApiAdapter(this._accounts);

  final FakeAccountApiAdapter _accounts;
  final _stored = <String, Map<Week, ({GroceryListChange change, int at})>>{};
  var _cursor = 0;
  bool unreachable = false;

  GroceryList? listOf(String email, Week week) =>
      _stored[email]?[week]?.change.list;

  void givenChange(String email, GroceryListChange change) =>
      _store(email, change);

  void tickOnOtherPhone(
    String email,
    Week week,
    String item, {
    bool ticked = true,
  }) {
    final current = _stored[email]![week]!.change;
    final list = current.list!;
    _store(
      email,
      GroceryListChange(
        week: week,
        updatedAt: current.updatedAt,
        list: GroceryList(
          id: list.id,
          week: week,
          recipes: list.recipes,
          items: [
            for (final i in list.items)
              i.ingredient.name == item
                  ? GroceryItem(
                      i.ingredient,
                      id: i.id,
                      ticked: ticked,
                      tickedAt: DateTime.now(),
                    )
                  : i,
          ],
        ),
      ),
    );
  }

  void planOnOtherPhone(String email, GroceryList list) => _store(
    email,
    GroceryListChange(week: list.week, updatedAt: DateTime.now(), list: list),
  );

  @override
  Future<void> push(String accessToken, List<GroceryListChange> changes) async {
    final email = _authenticate(accessToken);
    for (final change in changes) {
      _store(email, change);
    }
  }

  @override
  Future<GroceryListChangesPage> pull(
    String accessToken, {
    String? since,
  }) async {
    final email = _authenticate(accessToken);
    final after = int.parse(since ?? '0');
    final changes =
        (_stored[email]?.values.where((e) => e.at > after).toList() ?? [])
          ..sort((a, b) => a.at.compareTo(b.at));
    return GroceryListChangesPage(
      changes: [for (final e in changes) e.change],
      cursor: '${changes.isEmpty ? after : changes.last.at}',
      hasMore: false,
    );
  }

  void _store(String email, GroceryListChange change) {
    final weeks = _stored.putIfAbsent(email, () => {});
    final result = change.applyTo(weeks[change.week]?.change);
    if (result != null) weeks[change.week] = (change: result, at: ++_cursor);
  }

  String _authenticate(String accessToken) {
    if (unreachable) throw const GroceryListServerUnreachableException();
    return _accounts.emailFor(accessToken) ??
        (throw const AccessTokenRejectedException());
  }
}
