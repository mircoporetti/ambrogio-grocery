import 'dart:convert';

String _segment(Map<String, Object?> json) =>
    base64Url.encode(utf8.encode(jsonEncode(json))).replaceAll('=', '');

Map<String, Object?> _payloadOf(String token) =>
    jsonDecode(
          utf8.decode(
            base64Url.decode(base64Url.normalize(token.split('.')[1])),
          ),
        )
        as Map<String, Object?>;

String withClaims(String token, Map<String, Object?> claims) {
  final [header, _, signature] = token.split('.');
  return '$header.${_segment({..._payloadOf(token), ...claims})}.$signature';
}

String unsigned(String token) =>
    '${_segment({'alg': 'none', 'typ': 'JWT'})}.${_segment(_payloadOf(token))}.';
