import 'package:app/ui/core/date_format_day.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('formats the weekday', () {
    expect(dateFormatWeekday(DateTime(2026, 10, 26)), 'Monday');
  });

  test('formats ordinal day and month', () {
    expect(dateFormatDay(DateTime(2026, 10, 26)), '26th October');
  });

  test('uses the right ordinal suffix for each day', () {
    const expected = {
      1: '1st',
      2: '2nd',
      3: '3rd',
      4: '4th',
      11: '11th',
      12: '12th',
      13: '13th',
      21: '21st',
      22: '22nd',
      23: '23rd',
      31: '31st',
    };
    for (final MapEntry(key: day, value: ordinal) in expected.entries) {
      expect(dateFormatDay(DateTime(2026, 10, day)), '$ordinal October');
    }
  });
}
