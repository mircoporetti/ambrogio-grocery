import 'dart:io';

import 'package:ambrogio_backend/server.dart';

Future<void> main() async {
  final port = int.parse(Platform.environment['PORT'] ?? '8080');
  final server = await startServer(
    port: port,
    address: InternetAddress.anyIPv4,
  );
  stdout.writeln('Listening on port ${server.port}');
}
