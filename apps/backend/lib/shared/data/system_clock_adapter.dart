import '../domain/clock_port.dart';

class SystemClockAdapter implements ClockPort {
  @override
  DateTime now() => DateTime.now().toUtc();
}
