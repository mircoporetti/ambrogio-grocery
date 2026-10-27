import 'dart:convert';

import 'package:ambrogio_api_contract/ambrogio_api_contract.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';

import '../../accounts/application/authenticate.dart';
import '../../accounts/domain/account_exceptions.dart';
import '../../http/json.dart';
import '../application/pull_grocery_list_changes.dart';
import '../application/push_grocery_list_changes.dart';
import '../domain/grocery_exceptions.dart';
import '../domain/grocery_item.dart';
import '../domain/grocery_list.dart';
import '../domain/grocery_list_change.dart';
import '../domain/week.dart';

class GroceryListRoutes {
  GroceryListRoutes(this._authenticate, this._push, this._pull);

  final Authenticate _authenticate;
  final PushGroceryListChanges _push;
  final PullGroceryListChanges _pull;

  Router get router => Router()
    ..post(groceryListChangesPath, _guard(_pushChanges))
    ..get(groceryListChangesPath, _guard(_pullChanges));

  Future<Response> _pushChanges(Request request) async {
    final account = _authenticate(bearerToken(request));
    final body = PushGroceryListChangesRequest.fromJson(
      jsonDecode(await request.readAsString()),
    );
    await _push(account, body.changes.map(_toChange).toList());
    return Response(204);
  }

  Future<Response> _pullChanges(Request request) async {
    final account = _authenticate(bearerToken(request));
    final query = PullChangesRequest.fromQuery(request.url.queryParameters);
    final after = switch (query.since) {
      null => 0,
      final since => int.tryParse(since) ?? -1,
    };
    final limit = query.limit ?? PullGroceryListChanges.defaultLimit;
    if (after < 0 || limit < 1 || limit > PullGroceryListChanges.maxLimit) {
      throw const InvalidRequestException();
    }
    final page = await _pull(account, after: after, limit: limit);
    return jsonResponse(
      200,
      PullGroceryListChangesResponse(
        changes: page.changes.map(_toBody).toList(),
        cursor: '${page.cursor}',
        hasMore: page.hasMore,
      ).toJson(),
    );
  }

  GroceryListChange _toChange(GroceryListChangeBody body) => GroceryListChange(
    week: _parse(() => Week.fromKey(body.week)),
    updatedAt: body.updatedAt,
    list: switch (body.list) {
      null => null,
      final list => _parse(
        () => GroceryList(
          id: list.id,
          recipes: list.recipes,
          items: [
            for (final i in list.items)
              GroceryItem(
                id: i.id,
                name: i.name,
                quantity: i.quantity,
                unit:
                    MeasureUnit.fromSymbol(i.unit) ??
                    (throw const InvalidRequestException()),
                ticked: i.ticked,
                tickedAt: i.tickedAt,
              ),
          ],
        ),
      ),
    },
  );

  GroceryListChangeBody _toBody(GroceryListChange change) =>
      GroceryListChangeBody(
        week: change.week.key,
        updatedAt: change.updatedAt,
        list: switch (change.list) {
          null => null,
          final list => GroceryListBody(
            id: list.id,
            recipes: list.recipes,
            items: [
              for (final i in list.items)
                GroceryItemBody(
                  id: i.id,
                  name: i.name,
                  quantity: i.quantity,
                  unit: i.unit.symbol,
                  ticked: i.ticked,
                  tickedAt: i.tickedAt,
                ),
            ],
          ),
        },
      );

  T _parse<T>(T Function() create) {
    try {
      return create();
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
    } on GroceryListException catch (e) {
      return switch (e) {
        InvalidGroceryListException() => errorResponse(
          400,
          ErrorCodes.invalidGroceryList,
        ),
        TooManyGroceryListChangesException() => errorResponse(
          413,
          ErrorCodes.tooManyChanges,
        ),
      };
    }
  };
}
