import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('only the HTTP adapters import the API contract', () {
    final offenders = [
      for (final file in Directory('lib').listSync(recursive: true))
        if (file is File &&
            file.path.endsWith('.dart') &&
            !RegExp(r'/data/http_[a-z_]+_adapter\.dart$').hasMatch(file.path) &&
            file.readAsStringSync().contains('package:ambrogio_api_contract'))
          file.path,
    ];

    expect(offenders, isEmpty);
  });
}
