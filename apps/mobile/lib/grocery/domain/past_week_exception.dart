import 'week.dart';

class PastWeekException implements Exception {
  PastWeekException(this.week);

  final Week week;

  @override
  String toString() => 'PastWeekException($week)';
}
