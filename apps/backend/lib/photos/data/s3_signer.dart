import 'dart:convert';

import 'package:crypto/crypto.dart';

class S3Signer {
  S3Signer({
    required this.endpoint,
    required this.region,
    required this.accessKeyId,
    required String secretAccessKey,
  }) : _secretAccessKey = secretAccessKey;

  final Uri endpoint;
  final String region;
  final String accessKeyId;
  final String _secretAccessKey;

  Uri presign(
    String method,
    String path, {
    required DateTime now,
    required Duration expiresIn,
    Map<String, String> headers = const {},
  }) {
    final time = now.toUtc();
    final date = _date(time);
    final amzDate = '${date}T${_time(time)}Z';
    final scope = '$date/$region/s3/aws4_request';
    final signedHeaders = {
      for (final MapEntry(:key, :value) in headers.entries)
        key.toLowerCase(): value.trim(),
      'host': _host,
    };
    final headerNames = signedHeaders.keys.toList()..sort();
    final query = {
      'X-Amz-Algorithm': 'AWS4-HMAC-SHA256',
      'X-Amz-Credential': '$accessKeyId/$scope',
      'X-Amz-Date': amzDate,
      'X-Amz-Expires': '${expiresIn.inSeconds}',
      'X-Amz-SignedHeaders': headerNames.join(';'),
    };
    final canonicalPath = path.split('/').map(_encode).join('/');
    final canonicalQuery = _canonicalQuery(query);
    final canonicalRequest = [
      method,
      canonicalPath,
      canonicalQuery,
      for (final name in headerNames) '$name:${signedHeaders[name]}',
      '',
      headerNames.join(';'),
      'UNSIGNED-PAYLOAD',
    ].join('\n');
    final stringToSign = [
      'AWS4-HMAC-SHA256',
      amzDate,
      scope,
      sha256.convert(utf8.encode(canonicalRequest)).toString(),
    ].join('\n');
    final signature = Hmac(
      sha256,
      _signingKey(date),
    ).convert(utf8.encode(stringToSign)).toString();
    return Uri.parse(
      '${endpoint.scheme}://$_host$canonicalPath'
      '?$canonicalQuery&X-Amz-Signature=$signature',
    );
  }

  String get _host => endpoint.hasPort && endpoint.port != _defaultPort
      ? '${endpoint.host}:${endpoint.port}'
      : endpoint.host;

  int get _defaultPort => endpoint.scheme == 'https' ? 443 : 80;

  List<int> _signingKey(String date) {
    List<int> key = utf8.encode('AWS4$_secretAccessKey');
    for (final part in [date, region, 's3', 'aws4_request']) {
      key = Hmac(sha256, key).convert(utf8.encode(part)).bytes;
    }
    return key;
  }

  static String _canonicalQuery(Map<String, String> query) {
    final names = query.keys.toList()..sort();
    return [
      for (final name in names) '${_encode(name)}=${_encode(query[name]!)}',
    ].join('&');
  }

  // S3 needs RFC 3986: Uri.encodeComponent doesn't encode !*'().
  static String _encode(String value) {
    final out = StringBuffer();
    for (final byte in utf8.encode(value)) {
      final char = String.fromCharCode(byte);
      if (RegExp(r'[A-Za-z0-9\-_.~]').hasMatch(char)) {
        out.write(char);
      } else {
        out.write('%${byte.toRadixString(16).toUpperCase().padLeft(2, '0')}');
      }
    }
    return out.toString();
  }

  static String _date(DateTime t) =>
      '${t.year.toString().padLeft(4, '0')}${_two(t.month)}${_two(t.day)}';

  static String _time(DateTime t) =>
      '${_two(t.hour)}${_two(t.minute)}${_two(t.second)}';

  static String _two(int n) => n.toString().padLeft(2, '0');
}
