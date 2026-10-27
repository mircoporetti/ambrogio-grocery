class PullChangesRequest {
  const PullChangesRequest({this.since, this.limit});

  factory PullChangesRequest.fromQuery(Map<String, String> query) {
    final limit = query['limit'];
    return PullChangesRequest(
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

const maxChangesPerPush = 1000;
