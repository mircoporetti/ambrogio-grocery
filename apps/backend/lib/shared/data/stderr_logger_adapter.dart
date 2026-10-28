import 'dart:io';

import '../domain/logger_port.dart';

class StderrLoggerAdapter implements LoggerPort {
  @override
  void warning(String message) => stderr.writeln('WARNING: $message');
}
