import 'package:intl/intl.dart';

final _dateFormatTime = DateFormat('h:mm a');
final _dateFormatClock = DateFormat('h:mm');
final _dateFormatPeriod = DateFormat('a');

/// Formats a time as 12-hour with AM/PM, e.g. "8:30 AM".
String dateFormatTime(DateTime date) => _dateFormatTime.format(date);

/// Formats a time as 12-hour without AM/PM, e.g. "8:30".
String dateFormatClock(DateTime date) => _dateFormatClock.format(date);

/// Whether a time is before or after noon: "AM" or "PM".
String dateFormatPeriod(DateTime date) => _dateFormatPeriod.format(date);
