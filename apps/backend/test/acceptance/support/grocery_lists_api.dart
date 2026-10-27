import 'api_client.dart';

class GroceryListsApi {
  GroceryListsApi(this._api);

  final ApiClient _api;

  Future<ApiResponse> push(String? token, List<Map<String, Object?>> changes) =>
      _api.post('/grocery-lists/changes', {'changes': changes}, token: token);

  Future<ApiResponse> pushRaw(String? token, String body) =>
      _api.postRaw('/grocery-lists/changes', body, token: token);

  Future<ApiResponse> pull(String? token, {String? since, int? limit}) {
    final query = {'since': ?since, if (limit != null) 'limit': '$limit'};
    return _api.get(
      Uri(path: '/grocery-lists/changes', queryParameters: query).toString(),
      token: token,
    );
  }

  Future<List<Map<String, Object?>>> pullChanges(String token) async =>
      changesOf(await pull(token));

  static List<Map<String, Object?>> changesOf(ApiResponse response) => [
    for (final change in response['changes']! as List)
      change as Map<String, Object?>,
  ];
}

const week = '2026-10-19';
const nextWeek = '2026-10-26';

const listId = '3a1b2c3d-4e5f-4a6b-8c7d-9e0f1a2b3c4d';
const otherListId = '4b2c3d4e-5f6a-4b7c-9d8e-0f1a2b3c4d5e';
const guancialeId = '5c3d4e5f-6a7b-4c8d-8e9f-1a2b3c4d5e6f';
const spaghettiId = '6d4e5f6a-7b8c-4d9e-9f0a-2b3c4d5e6f7a';

String utc(DateTime time) => time.toUtc().toIso8601String();

Map<String, Object?> item(
  String id,
  String name, {
  bool ticked = false,
  DateTime? tickedAt,
}) => {
  'id': id,
  'name': name,
  'quantity': 150.0,
  'unit': 'g',
  'ticked': ticked,
  'tickedAt': tickedAt == null ? null : utc(tickedAt),
};

Map<String, Object?> carbonaraList({
  String id = listId,
  List<Map<String, Object?>>? items,
}) => {
  'id': id,
  'recipes': ['Carbonara'],
  'items':
      items ?? [item(guancialeId, 'Guanciale'), item(spaghettiId, 'Spaghetti')],
};

Map<String, Object?> listChange(
  Map<String, Object?> list, {
  required DateTime at,
  String forWeek = week,
}) => {'week': forWeek, 'updatedAt': utc(at), 'deleted': false, 'list': list};

Map<String, Object?> listDeletion({
  required DateTime at,
  String forWeek = week,
}) => {'week': forWeek, 'updatedAt': utc(at), 'deleted': true};
