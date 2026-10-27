import 'package:ambrogio_backend/accounts/domain/clock_port.dart';

final today = DateTime.utc(2026, 10, 21, 10);

class FixedClockAdapter implements ClockPort {
  FixedClockAdapter([DateTime? now]) : _now = now ?? today;

  DateTime _now;

  void advance(Duration duration) => _now = _now.add(duration);

  @override
  DateTime now() => _now;
}
