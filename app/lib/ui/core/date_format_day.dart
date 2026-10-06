import 'package:intl/intl.dart';

final _dateFormatWeekday = DateFormat('EEEE');
final _dateFormatMonth = DateFormat('MMMM');

/// Formats a date as a day title, e.g. "Monday, 26th October".
String dateFormatDay(DateTime date) {
  final weekday = _dateFormatWeekday.format(date);
  final month = _dateFormatMonth.format(date);
  return '$weekday, ${_ordinal(date.day)} $month';
}

String _ordinal(int day) {
  if (day >= 11 && day <= 13) return '${day}th';
  return switch (day % 10) {
    1 => '${day}st',
    2 => '${day}nd',
    3 => '${day}rd',
    _ => '${day}th',
  };
}
