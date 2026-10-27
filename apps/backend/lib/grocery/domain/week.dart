import 'grocery_exceptions.dart';

class Week implements Comparable<Week> {
  Week._(this.monday);

  factory Week.fromKey(String key) {
    final day = RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(key)
        ? DateTime.tryParse('${key}T00:00:00Z')
        : null;
    if (day == null || _keyOf(day) != key) {
      throw ArgumentError.value(key, 'key', 'must be a date as yyyy-mm-dd');
    }
    if (day.weekday != DateTime.monday) {
      throw const InvalidGroceryListException('a week starts on Monday');
    }
    return Week._(day);
  }

  final DateTime monday;

  String get key => _keyOf(monday);

  static String _keyOf(DateTime day) => day.toIso8601String().substring(0, 10);

  @override
  int compareTo(Week other) => monday.compareTo(other.monday);

  @override
  bool operator ==(Object other) => other is Week && other.monday == monday;

  @override
  int get hashCode => monday.hashCode;

  @override
  String toString() => 'Week($key)';
}
