import 'dart:io';

import 'package:test/test.dart';

void main() {
  test('only the HTTP layer imports the API contract', () {
    final offenders = [
      for (final file in Directory('lib').listSync(recursive: true))
        if (file is File &&
            file.path.endsWith('.dart') &&
            RegExp(r'/(domain|application|data)/').hasMatch(file.path) &&
            file.readAsStringSync().contains('package:ambrogio_api_contract'))
          file.path,
    ];

    expect(offenders, isEmpty);
  });
}
