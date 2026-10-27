import 'dart:convert';

import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import 'package:uuid/uuid.dart';

import '../domain/access_token.dart';
import '../domain/access_token_port.dart';
import '../domain/account_id.dart';

class JwtAccessTokenAdapter implements AccessTokenPort {
  JwtAccessTokenAdapter(String secret) : _key = SecretKey(secret) {
    if (utf8.encode(secret).length < 32) {
      throw ArgumentError.value('***', 'secret', 'must be at least 32 bytes');
    }
  }

  final SecretKey _key;

  static const _issuer = 'ambrogio';

  @override
  AccessToken issue(AccountId accountId, DateTime now) {
    final expiresAt = now.add(AccessToken.lifetime);
    // The library reads the system clock for iat and exp, so they're set
    // here from [now] instead.
    final jwt = JWT(
      {'iat': _seconds(now), 'exp': _seconds(expiresAt)},
      subject: accountId.value,
      issuer: _issuer,
      jwtId: const Uuid().v4(),
    );
    return AccessToken(
      value: jwt.sign(_key, algorithm: JWTAlgorithm.HS256, noIssueAt: true),
      expiresAt: expiresAt,
    );
  }

  @override
  AccountId? verify(String token, DateTime now) {
    // Only HS256: the library picks the algorithm from the token's own
    // header, so a forged header must not choose it.
    if (_algorithm(token) != 'HS256') return null;
    final JWT jwt;
    try {
      jwt = JWT.verify(token, _key, checkExpiresIn: false, issuer: _issuer);
    } on JWTException {
      return null;
    }
    final payload = jwt.payload;
    final subject = jwt.subject;
    if (payload is! Map || subject == null) return null;
    final exp = payload['exp'];
    if (exp is! int || _seconds(now) >= exp) return null;
    if (!Uuid.isValidUUID(fromString: subject)) return null;
    return AccountId(subject);
  }

  static Object? _algorithm(String token) {
    try {
      final header = token.split('.').first;
      final json = jsonDecode(
        utf8.decode(base64Url.decode(base64Url.normalize(header))),
      );
      return json is Map ? json['alg'] : null;
    } on FormatException {
      return null;
    }
  }

  static int _seconds(DateTime time) => time.millisecondsSinceEpoch ~/ 1000;
}
