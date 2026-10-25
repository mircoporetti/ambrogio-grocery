import '../domain/week.dart';

const _months = [
  'Jan',
  'Feb',
  'Mar',
  'Apr',
  'May',
  'Jun',
  'Jul',
  'Aug',
  'Sep',
  'Oct',
  'Nov',
  'Dec',
];

String formatWeek(Week week) {
  final start = week.start;
  final end = week.end;
  final endText = '${end.day} ${_months[end.month - 1]}';
  if (start.year != end.year) {
    return '${start.day} ${_months[start.month - 1]} ${start.year}'
        ' – $endText ${end.year}';
  }
  if (start.month != end.month) {
    return '${start.day} ${_months[start.month - 1]} – $endText';
  }
  return '${start.day} – $endText';
}

String formatRecipeCount(int count) =>
    count == 1 ? '1 recipe' : '$count recipes';
