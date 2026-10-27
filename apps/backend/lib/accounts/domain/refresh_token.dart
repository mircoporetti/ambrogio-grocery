import 'dart:convert';
import 'dart:math';

import 'session.dart';

class RefreshToken {
  RefreshToken({
    required this.value,
    required this.session,
    required this.expiresAt,
    this.used = false,
  });

  RefreshToken.issue(this.session, DateTime now)
    : value = _randomValue(),
      expiresAt = now.add(lifetime),
      used = false;

  static const lifetime = Duration(days: 30);

  final String value;
  final Session session;
  final DateTime expiresAt;

  final bool used;

  bool isActiveAt(DateTime now) => now.isBefore(expiresAt);

  static String _randomValue() {
    final random = Random.secure();
    final bytes = List<int>.generate(32, (_) => random.nextInt(256));
    return base64Url.encode(bytes).replaceAll('=', '');
  }
}
