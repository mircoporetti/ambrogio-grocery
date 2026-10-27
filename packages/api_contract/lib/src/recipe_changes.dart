import 'json.dart';

const recipeChangesPath = '/recipes/changes';

const maxRecipeChangesPerPush = 1000;

class IngredientBody {
  const IngredientBody({
    required this.name,
    required this.quantity,
    required this.unit,
  });

  factory IngredientBody.fromJson(Object? json) {
    final object = asObject(json);
    return IngredientBody(
      name: readString(object, 'name'),
      quantity: readNumber(object, 'quantity'),
      unit: readString(object, 'unit'),
    );
  }

  final String name;
  final double quantity;

  final String unit;

  Map<String, Object?> toJson() => {
    'name': name,
    'quantity': quantity,
    'unit': unit,
  };
}

class RecipeBody {
  const RecipeBody({
    required this.title,
    required this.portions,
    required this.ingredients,
    this.procedure,
    this.photoId,
    this.categories = const [],
  });

  factory RecipeBody.fromJson(Object? json) {
    final object = asObject(json);
    return RecipeBody(
      title: readString(object, 'title'),
      portions: readInt(object, 'portions'),
      procedure: readOptionalString(object, 'procedure'),
      photoId: readOptionalString(object, 'photoId'),
      categories: [
        for (final category in readList(object, 'categories'))
          switch (category) {
            final String name => name,
            _ => throw const FormatException('Expected category names'),
          },
      ],
      ingredients: readList(
        object,
        'ingredients',
      ).map(IngredientBody.fromJson).toList(),
    );
  }

  final String title;
  final int portions;
  final String? procedure;
  final String? photoId;
  final List<String> categories;
  final List<IngredientBody> ingredients;

  Map<String, Object?> toJson() => {
    'title': title,
    'portions': portions,
    'procedure': procedure,
    'photoId': photoId,
    'categories': categories,
    'ingredients': [for (final i in ingredients) i.toJson()],
  };
}

class RecipeChangeBody {
  RecipeChangeBody({required this.id, required DateTime updatedAt, this.recipe})
    : updatedAt = updatedAt.toUtc();

  factory RecipeChangeBody.fromJson(Object? json) {
    final object = asObject(json);
    final deleted = readBool(object, 'deleted');
    return RecipeChangeBody(
      id: readString(object, 'id'),
      updatedAt: readUtcTime(object, 'updatedAt'),
      recipe: deleted ? null : RecipeBody.fromJson(object['recipe']),
    );
  }

  final String id;
  final DateTime updatedAt;
  final RecipeBody? recipe;

  bool get deleted => recipe == null;

  Map<String, Object?> toJson() => {
    'id': id,
    'updatedAt': updatedAt.toIso8601String(),
    'deleted': deleted,
    if (recipe case final recipe?) 'recipe': recipe.toJson(),
  };
}

class PushRecipeChangesRequest {
  const PushRecipeChangesRequest(this.changes);

  factory PushRecipeChangesRequest.fromJson(Object? json) =>
      PushRecipeChangesRequest(
        readList(
          asObject(json),
          'changes',
        ).map(RecipeChangeBody.fromJson).toList(),
      );

  final List<RecipeChangeBody> changes;

  Map<String, Object?> toJson() => {
    'changes': [for (final change in changes) change.toJson()],
  };
}

class PullRecipeChangesRequest {
  const PullRecipeChangesRequest({this.since, this.limit});

  factory PullRecipeChangesRequest.fromQuery(Map<String, String> query) {
    final limit = query['limit'];
    return PullRecipeChangesRequest(
      since: query['since'],
      limit: limit == null
          ? null
          : int.tryParse(limit) ??
                (throw const FormatException('Expected an integer limit')),
    );
  }

  final String? since;
  final int? limit;

  Map<String, String> toQuery() => {
    'since': ?since,
    if (limit case final limit?) 'limit': '$limit',
  };
}

class PullRecipeChangesResponse {
  const PullRecipeChangesResponse({
    required this.changes,
    required this.cursor,
    required this.hasMore,
  });

  factory PullRecipeChangesResponse.fromJson(Object? json) {
    final object = asObject(json);
    return PullRecipeChangesResponse(
      changes: readList(
        object,
        'changes',
      ).map(RecipeChangeBody.fromJson).toList(),
      cursor: readString(object, 'cursor'),
      hasMore: readBool(object, 'hasMore'),
    );
  }

  final List<RecipeChangeBody> changes;
  final String cursor;
  final bool hasMore;

  Map<String, Object?> toJson() => {
    'changes': [for (final change in changes) change.toJson()],
    'cursor': cursor,
    'hasMore': hasMore,
  };
}
