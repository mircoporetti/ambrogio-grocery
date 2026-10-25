import 'package:ambrogio_grocery/grocery/domain/clock_port.dart';

class FixedClockAdapter implements ClockPort {
  FixedClockAdapter(this.today);

  DateTime today;

  @override
  DateTime now() => today;
}
