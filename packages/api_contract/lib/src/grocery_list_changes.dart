import 'json.dart';

const groceryListChangesPath = '/grocery-lists/changes';

class GroceryItemBody {
  GroceryItemBody({
    required this.id,
    required this.name,
    required this.quantity,
    required this.unit,
    required this.ticked,
    DateTime? tickedAt,
  }) : tickedAt = tickedAt?.toUtc();

  factory GroceryItemBody.fromJson(Object? json) {
    final object = asObject(json);
    return GroceryItemBody(
      id: readString(object, 'id'),
      name: readString(object, 'name'),
      quantity: readNumber(object, 'quantity'),
      unit: readString(object, 'unit'),
      ticked: readBool(object, 'ticked'),
      tickedAt: object['tickedAt'] == null
          ? null
          : readUtcTime(object, 'tickedAt'),
    );
  }

  final String id;
  final String name;
  final double quantity;

  final String unit;
  final bool ticked;

  final DateTime? tickedAt;

  Map<String, Object?> toJson() => {
    'id': id,
    'name': name,
    'quantity': quantity,
    'unit': unit,
    'ticked': ticked,
    'tickedAt': tickedAt?.toIso8601String(),
  };
}

class GroceryListBody {
  const GroceryListBody({
    required this.id,
    required this.recipes,
    required this.items,
  });

  factory GroceryListBody.fromJson(Object? json) {
    final object = asObject(json);
    return GroceryListBody(
      id: readString(object, 'id'),
      recipes: [
        for (final recipe in readList(object, 'recipes'))
          switch (recipe) {
            final String title => title,
            _ => throw const FormatException('Expected recipe titles'),
          },
      ],
      items: readList(object, 'items').map(GroceryItemBody.fromJson).toList(),
    );
  }

  /// A new id means the week was planned again: the list replaces the old
  /// one instead of merging ticks with it.
  final String id;
  final List<String> recipes;
  final List<GroceryItemBody> items;

  Map<String, Object?> toJson() => {
    'id': id,
    'recipes': recipes,
    'items': [for (final item in items) item.toJson()],
  };
}

class GroceryListChangeBody {
  GroceryListChangeBody({
    required this.week,
    required DateTime updatedAt,
    this.list,
  }) : updatedAt = updatedAt.toUtc();

  factory GroceryListChangeBody.fromJson(Object? json) {
    final object = asObject(json);
    final deleted = readBool(object, 'deleted');
    return GroceryListChangeBody(
      week: readString(object, 'week'),
      updatedAt: readUtcTime(object, 'updatedAt'),
      list: deleted ? null : GroceryListBody.fromJson(object['list']),
    );
  }

  final String week;

  /// When the week was last planned or deleted; ticking doesn't change it.
  final DateTime updatedAt;
  final GroceryListBody? list;

  bool get deleted => list == null;

  Map<String, Object?> toJson() => {
    'week': week,
    'updatedAt': updatedAt.toIso8601String(),
    'deleted': deleted,
    if (list case final list?) 'list': list.toJson(),
  };
}

class PushGroceryListChangesRequest {
  const PushGroceryListChangesRequest(this.changes);

  factory PushGroceryListChangesRequest.fromJson(Object? json) =>
      PushGroceryListChangesRequest(
        readList(
          asObject(json),
          'changes',
        ).map(GroceryListChangeBody.fromJson).toList(),
      );

  final List<GroceryListChangeBody> changes;

  Map<String, Object?> toJson() => {
    'changes': [for (final change in changes) change.toJson()],
  };
}

class PullGroceryListChangesResponse {
  const PullGroceryListChangesResponse({
    required this.changes,
    required this.cursor,
    required this.hasMore,
  });

  factory PullGroceryListChangesResponse.fromJson(Object? json) {
    final object = asObject(json);
    return PullGroceryListChangesResponse(
      changes: readList(
        object,
        'changes',
      ).map(GroceryListChangeBody.fromJson).toList(),
      cursor: readString(object, 'cursor'),
      hasMore: readBool(object, 'hasMore'),
    );
  }

  final List<GroceryListChangeBody> changes;
  final String cursor;
  final bool hasMore;

  Map<String, Object?> toJson() => {
    'changes': [for (final change in changes) change.toJson()],
    'cursor': cursor,
    'hasMore': hasMore,
  };
}
