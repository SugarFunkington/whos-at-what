import 'package:app/domain/models/event.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('fromJson reads the members and details', () {
    final event = Event.fromJson({
      'id': '1',
      'title': 'Swimming',
      'starts_at': '2026-10-07T15:00:00+00:00',
      'all_day': false,
      'duration': '01:30:00',
      'location': 'Leisure Centre, Main St',
      'emoji': '🏊',
      'notes': 'Bring goggles',
      'event_members': [
        {'member_id': 'ella'},
        {'member_id': 'parent'},
      ],
    });

    expect(event.memberIds, ['ella', 'parent']);
    expect(event.duration, const Duration(hours: 1, minutes: 30));
    expect(event.location, 'Leisure Centre, Main St');
    expect(event.emoji, '🏊');
    expect(event.notes, 'Bring goggles');
  });

  test('fromJson reads a whole-family event with no extras', () {
    final event = Event.fromJson({
      'id': '2',
      'title': 'Bins out',
      'starts_at': '2026-10-07T05:00:00+00:00',
      'all_day': false,
      'duration': null,
      'location': null,
      'emoji': null,
      'notes': null,
      'event_members': [],
    });

    expect(event.memberIds, isEmpty);
    expect(event.duration, isNull);
    expect(event.location, isNull);
    expect(event.emoji, isNull);
    expect(event.notes, isNull);
  });

  test('fromJson reads a duration of more than a day', () {
    final event = Event.fromJson({
      'id': '3',
      'title': 'Camping',
      'starts_at': '2026-10-07T09:00:00+00:00',
      'all_day': true,
      'duration': '2 days 01:00:00',
      'location': null,
      'emoji': null,
      'event_members': [],
    });

    expect(event.allDay, isTrue);
    expect(event.duration, const Duration(days: 2, hours: 1));
  });
}
