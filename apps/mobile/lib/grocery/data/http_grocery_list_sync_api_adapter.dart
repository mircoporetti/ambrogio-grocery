import 'dart:async';
import 'dart:convert';

import 'package:ambrogio_api_contract/ambrogio_api_contract.dart';
import 'package:http/http.dart' as http;

import '../../account/domain/account_exceptions.dart';
import '../../recipes/domain/ingredient.dart';
import '../domain/grocery_item.dart';
import '../domain/grocery_item_id.dart';
import '../domain/grocery_list.dart';
import '../domain/grocery_list_change.dart';
import '../domain/grocery_list_id.dart';
import '../domain/grocery_list_sync_api_port.dart';
import '../domain/grocery_list_sync_exceptions.dart';
import '../domain/week.dart';

class HttpGroceryListSyncApiAdapter implements GroceryListSyncApiPort {
  HttpGroceryListSyncApiAdapter(this._baseUrl, this._client);

  final Uri _baseUrl;
  final http.Client _client;

  static const _timeout = Duration(seconds: 30);

  @override
  Future<void> push(String accessToken, List<GroceryListChange> changes) async {
    final request =
        http.Request('POST', _baseUrl.resolve(groceryListChangesPath))
          ..headers['content-type'] = 'application/json'
          ..body = jsonEncode(
            PushGroceryListChangesRequest(
              changes.map(_toBody).toList(),
            ).toJson(),
          );
    await _send(request, accessToken);
  }

  @override
  Future<GroceryListChangesPage> pull(
    String accessToken, {
    String? since,
  }) async {
    final url = _baseUrl
        .resolve(groceryListChangesPath)
        .replace(queryParameters: PullChangesRequest(since: since).toQuery());
    final body = await _send(http.Request('GET', url), accessToken);
    try {
      final response = PullGroceryListChangesResponse.fromJson(
        jsonDecode(body),
      );
      return GroceryListChangesPage(
        changes: response.changes.map(_toChange).toList(),
        cursor: response.cursor,
        hasMore: response.hasMore,
      );
    } on FormatException {
      throw const UnexpectedGroceryListResponseException();
    } on ArgumentError {
      throw const UnexpectedGroceryListResponseException();
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
      throw const GroceryListServerUnreachableException();
    } on TimeoutException {
      throw const GroceryListServerUnreachableException();
    }
    final status = response.statusCode;
    if (status >= 200 && status < 300) return response.body;
    if (status == 401) throw const AccessTokenRejectedException();
    throw const UnexpectedGroceryListResponseException();
  }

  GroceryListChangeBody _toBody(GroceryListChange change) =>
      GroceryListChangeBody(
        week: change.week.key,
        updatedAt: change.updatedAt,
        list: switch (change.list) {
          null => null,
          final list => GroceryListBody(
            id: list.id.value,
            recipes: list.recipes,
            items: [
              for (final item in list.items)
                GroceryItemBody(
                  id: item.id.value,
                  name: item.ingredient.name,
                  quantity: item.ingredient.quantity,
                  unit: item.ingredient.unit.symbol,
                  ticked: item.ticked,
                  tickedAt: item.tickedAt,
                ),
            ],
          ),
        },
      );

  GroceryListChange _toChange(GroceryListChangeBody body) {
    final week = Week.fromKey(body.week);
    return GroceryListChange(
      week: week,
      updatedAt: body.updatedAt,
      list: switch (body.list) {
        null => null,
        final list => GroceryList(
          id: GroceryListId(list.id),
          week: week,
          recipes: list.recipes,
          items: [
            for (final item in list.items)
              GroceryItem(
                Ingredient(
                  name: item.name,
                  quantity: item.quantity,
                  unit: MeasureUnit.values.firstWhere(
                    (unit) => unit.symbol == item.unit,
                    orElse: () => throw const FormatException('Unknown unit'),
                  ),
                ),
                id: GroceryItemId(item.id),
                ticked: item.ticked,
                tickedAt: item.tickedAt,
              ),
          ],
        ),
      },
    );
  }
}
