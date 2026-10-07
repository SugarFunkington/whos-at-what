import 'package:app/ui/core/date_format_time.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('formats as 24-hour with leading zeros', () {
    expect(dateFormatTime(DateTime(2026, 10, 26, 8, 30)), '08:30');
    expect(dateFormatTime(DateTime(2026, 10, 26, 18, 5)), '18:05');
  });
}
