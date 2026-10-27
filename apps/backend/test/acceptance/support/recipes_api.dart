import 'api_client.dart';

class RecipesApi {
  RecipesApi(this._api);

  final ApiClient _api;

  Future<ApiResponse> push(String? token, List<Map<String, Object?>> changes) =>
      _api.post('/recipes/changes', {'changes': changes}, token: token);

  Future<ApiResponse> pushRaw(String? token, String body) =>
      _api.postRaw('/recipes/changes', body, token: token);

  Future<ApiResponse> pull(String? token, {String? since, int? limit}) {
    final query = {'since': ?since, if (limit != null) 'limit': '$limit'};
    return _api.get(
      Uri(path: '/recipes/changes', queryParameters: query).toString(),
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

const pasta = {
  'title': 'Pasta al pomodoro',
  'portions': 2,
  'procedure': 'Boil the pasta, warm the sauce.',
  'photoId': '6f1c8a52-3c1e-4f0a-9d47-1a2b3c4d5e6f',
  'categories': ['First course', 'Quick'],
  'ingredients': [
    {'name': 'Spaghetti', 'quantity': 200.0, 'unit': 'g'},
    {'name': 'Tomato sauce', 'quantity': 250.0, 'unit': 'ml'},
  ],
};

const salad = {
  'title': 'Green salad',
  'portions': 1,
  'procedure': null,
  'photoId': null,
  'categories': <String>[],
  'ingredients': [
    {'name': 'Lettuce', 'quantity': 150.0, 'unit': 'g'},
  ],
};

Map<String, Object?> upsert(
  String id,
  Map<String, Object?> recipe, {
  required DateTime at,
}) => {
  'id': id,
  'updatedAt': at.toUtc().toIso8601String(),
  'deleted': false,
  'recipe': recipe,
};

Map<String, Object?> deletion(String id, {required DateTime at}) => {
  'id': id,
  'updatedAt': at.toUtc().toIso8601String(),
  'deleted': true,
};
