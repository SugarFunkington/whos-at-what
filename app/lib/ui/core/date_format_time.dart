import 'package:intl/intl.dart';

final _dateFormatTime = DateFormat('HH:mm');

/// Formats a time as 24-hour, e.g. "08:30".
String dateFormatTime(DateTime date) => _dateFormatTime.format(date);
