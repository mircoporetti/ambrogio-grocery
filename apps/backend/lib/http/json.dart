import 'dart:convert';

import 'package:shelf/shelf.dart';

Response jsonResponse(
  int status,
  Object? body, {
  Map<String, String> headers = const {},
}) => Response(
  status,
  body: jsonEncode(body),
  headers: {'content-type': 'application/json', ...headers},
);

Response errorResponse(
  int status,
  String code, {
  Map<String, String> headers = const {},
}) => jsonResponse(status, {'error': code}, headers: headers);

class InvalidRequestException implements Exception {
  const InvalidRequestException();
}

Future<Map<String, String>> readStringFields(
  Request request,
  List<String> fields,
) async {
  final Object? body;
  try {
    body = jsonDecode(await request.readAsString());
  } on FormatException {
    throw const InvalidRequestException();
  }
  if (body is! Map<String, Object?>) throw const InvalidRequestException();
  return {
    for (final field in fields)
      field: switch (body[field]) {
        final String value => value,
        _ => throw const InvalidRequestException(),
      },
  };
}

String? bearerToken(Request request) {
  final header = request.headers['authorization'];
  if (header == null) return null;
  return RegExp(
    r'^Bearer\s+(\S+)$',
    caseSensitive: false,
  ).firstMatch(header.trim())?.group(1);
}
