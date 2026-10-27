Map<String, Object?> asObject(Object? json) => switch (json) {
  final Map<String, Object?> object => object,
  _ => throw const FormatException('Expected a JSON object'),
};

List<Object?> readList(Map<String, Object?> json, String key) =>
    switch (json[key]) {
      final List<Object?> list => list,
      _ => throw FormatException('Expected a list in "$key"'),
    };

String readString(Map<String, Object?> json, String key) => switch (json[key]) {
  final String value => value,
  _ => throw FormatException('Expected a string in "$key"'),
};

String? readOptionalString(Map<String, Object?> json, String key) =>
    switch (json[key]) {
      null => null,
      final String value => value,
      _ => throw FormatException('Expected a string or null in "$key"'),
    };

int readInt(Map<String, Object?> json, String key) => switch (json[key]) {
  final int value => value,
  _ => throw FormatException('Expected an integer in "$key"'),
};

double readNumber(Map<String, Object?> json, String key) => switch (json[key]) {
  final num value => value.toDouble(),
  _ => throw FormatException('Expected a number in "$key"'),
};

bool readBool(Map<String, Object?> json, String key) => switch (json[key]) {
  final bool value => value,
  _ => throw FormatException('Expected a boolean in "$key"'),
};

/// A UTC time: without an offset each side would read it in its own zone.
DateTime readUtcTime(Map<String, Object?> json, String key) {
  final time = DateTime.tryParse(readString(json, key));
  if (time == null || !time.isUtc) {
    throw FormatException('Expected a UTC time in "$key"');
  }
  return time;
}
