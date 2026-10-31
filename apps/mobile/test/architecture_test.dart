import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  List<String> filesInLib(bool Function(String path, String source) offends) =>
      [
        for (final file in Directory('lib').listSync(recursive: true))
          if (file is File &&
              file.path.endsWith('.dart') &&
              offends(file.path, file.readAsStringSync()))
            file.path,
      ];

  test('only the HTTP adapters import the API contract', () {
    final offenders = filesInLib(
      (path, source) =>
          !RegExp(r'/data/http_[a-z_]+_adapter\.dart$').hasMatch(path) &&
          source.contains('package:ambrogio_api_contract'),
    );

    expect(offenders, isEmpty);
  });

  test('code shared with the web build does not import dart:io', () {
    final offenders = filesInLib(
      (path, source) =>
          !RegExp(r'/data/(?!http_)[a-z_]+_adapter\.dart$').hasMatch(path) &&
          !path.endsWith('_io.dart') &&
          source.contains("import 'dart:io'"),
    );

    expect(offenders, isEmpty);
  });
}
