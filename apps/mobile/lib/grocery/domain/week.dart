class Week implements Comparable<Week> {
  Week.containing(DateTime day)
    : start = DateTime(
        day.year,
        day.month,
        day.day - (day.weekday - DateTime.monday),
      );

  factory Week.startingOn(DateTime monday) {
    if (monday.weekday != DateTime.monday) {
      throw ArgumentError.value(monday, 'monday', 'must be a Monday');
    }
    return Week.containing(monday);
  }

  final DateTime start;

  DateTime get end => DateTime(start.year, start.month, start.day + 6);

  Week get next =>
      Week.containing(DateTime(start.year, start.month, start.day + 7));

  Week get previous =>
      Week.containing(DateTime(start.year, start.month, start.day - 7));

  bool isBefore(Week other) => compareTo(other) < 0;

  @override
  int compareTo(Week other) => start.compareTo(other.start);

  @override
  bool operator ==(Object other) => other is Week && other.start == start;

  @override
  int get hashCode => start.hashCode;

  @override
  String toString() => 'Week(${start.toIso8601String().substring(0, 10)})';
}
