import 'package:app/ui/core/date_format_time.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('formats as 12-hour with AM/PM and no leading zero', () {
    expect(dateFormatTime(DateTime(2026, 10, 26, 8, 30)), '8:30 AM');
    expect(dateFormatTime(DateTime(2026, 10, 26, 18, 5)), '6:05 PM');
  });

  test('noon is 12 PM and midnight is 12 AM', () {
    expect(dateFormatTime(DateTime(2026, 10, 26, 12)), '12:00 PM');
    expect(dateFormatTime(DateTime(2026, 10, 26)), '12:00 AM');
  });

  test('splits into the clock and the period', () {
    final time = DateTime(2026, 10, 26, 18, 5);
    expect(dateFormatClock(time), '6:05');
    expect(dateFormatPeriod(time), 'PM');
    expect(dateFormatPeriod(DateTime(2026, 10, 26, 8, 30)), 'AM');
  });
}
