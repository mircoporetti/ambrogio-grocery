import '../domain/clock_port.dart';
import '../domain/week.dart';

class GetCurrentWeek {
  GetCurrentWeek(this._clock);

  final ClockPort _clock;

  Week call() => Week.containing(_clock.now());
}
