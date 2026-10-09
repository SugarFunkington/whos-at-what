import 'package:app/domain/models/event.dart';
import 'package:app/domain/models/member.dart';
import 'package:app/ui/home/widgets/event_card.dart';
import 'package:app/ui/home/widgets/time_slot.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Future<void> pumpSlot(WidgetTester tester, List<Event> events) {
    return tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: TimeSlot(
            events: events,
            membersFor: (event) => const <Member>[],
          ),
        ),
      ),
    );
  }

  testWidgets('shows the time once, with a dot and a card per event', (
    tester,
  ) async {
    await pumpSlot(tester, [
      Event(id: '1', title: 'Swimming', startsAt: DateTime(2026, 10, 26, 16)),
      Event(id: '2', title: 'Football', startsAt: DateTime(2026, 10, 26, 16)),
    ]);

    expect(find.text('16:00'), findsOneWidget);
    expect(find.byType(TimelineDot), findsNWidgets(2));
    expect(find.byType(EventCard), findsNWidgets(2));
  });

  testWidgets('shows "All day" for all-day events', (tester) async {
    await pumpSlot(tester, [
      Event(
        id: '1',
        title: 'Birthday',
        startsAt: DateTime(2026, 10, 26),
        allDay: true,
      ),
    ]);

    expect(find.text('All day'), findsOneWidget);
    expect(find.text('00:00'), findsNothing);
  });

  testWidgets('each dot overlaps the one above', (tester) async {
    await pumpSlot(tester, [
      Event(id: '1', title: 'Swimming', startsAt: DateTime(2026, 10, 26, 16)),
      Event(id: '2', title: 'Football', startsAt: DateTime(2026, 10, 26, 16)),
    ]);

    final dots = find.byType(TimelineDot);
    final first = tester.getTopLeft(dots.at(0));
    final second = tester.getTopLeft(dots.at(1));
    expect(second.dx, first.dx);
    expect(second.dy - first.dy, TimelineDot.size - TimelineDot.overlap);
  });
}
