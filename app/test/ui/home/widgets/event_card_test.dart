import 'package:app/domain/models/event.dart';
import 'package:app/domain/models/member.dart';
import 'package:app/ui/core/member_avatar.dart';
import 'package:app/ui/home/widgets/event_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const parent = Member(id: 'parent', displayName: 'Parent');
  const ella = Member(id: 'ella', displayName: 'Ella');

  Future<void> pumpCard(
    WidgetTester tester,
    Event event, {
    List<Member> members = const [],
  }) {
    return tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: EventCard(event: event, members: members),
        ),
      ),
    );
  }

  testWidgets('shows the emoji, title, end time and location', (tester) async {
    await pumpCard(
      tester,
      Event(
        id: '1',
        title: 'Swimming',
        startsAt: DateTime(2026, 10, 26, 8, 30),
        duration: const Duration(hours: 1),
        emoji: '🏊',
        location: 'Leisure Centre',
        memberIds: ['ella'],
      ),
      members: [ella],
    );

    expect(find.text('🏊'), findsOneWidget);
    expect(find.text('Swimming'), findsOneWidget);
    expect(find.text('until 09:30'), findsOneWidget);
    expect(find.text('Leisure Centre'), findsOneWidget);
  });

  testWidgets('shows the end time and location on their own lines', (
    tester,
  ) async {
    await pumpCard(
      tester,
      Event(
        id: '1',
        title: 'Swimming',
        startsAt: DateTime(2026, 10, 26, 8, 30),
        duration: const Duration(hours: 1),
        location: 'Leisure Centre',
      ),
    );

    final endTime = find.text('until 09:30');
    final location = find.text('Leisure Centre');
    expect(
      tester.getTopLeft(location).dy,
      greaterThan(tester.getBottomLeft(endTime).dy - 1),
    );
    expect(find.byIcon(Icons.schedule_outlined), findsOneWidget);
    expect(find.byIcon(Icons.location_on_outlined), findsOneWidget);
  });

  testWidgets('shows just the title without any extras', (tester) async {
    await pumpCard(
      tester,
      Event(
        id: '1',
        title: 'Football',
        startsAt: DateTime(2026, 10, 26, 10),
        memberIds: ['ella'],
      ),
      members: [ella],
    );

    final texts = tester.widgetList<Text>(find.byType(Text)).map((t) => t.data);
    expect(texts, ['Football', 'E']);
    expect(find.byType(Chip), findsNothing);
    expect(find.byType(Icon), findsNothing);
  });

  testWidgets('shows the notes in a chip', (tester) async {
    await pumpCard(
      tester,
      Event(
        id: '1',
        title: 'Swimming',
        startsAt: DateTime(2026, 10, 26, 16),
        notes: 'Bring goggles',
      ),
    );

    expect(find.widgetWithText(Chip, 'Bring goggles'), findsOneWidget);
  });

  testWidgets('shows an avatar for each member', (tester) async {
    await pumpCard(
      tester,
      Event(
        id: '1',
        title: 'Hurling',
        startsAt: DateTime(2026, 10, 26, 18),
        memberIds: ['parent', 'ella'],
      ),
      members: [parent, ella],
    );

    expect(find.byType(MemberAvatar), findsNWidgets(2));
    expect(find.byType(FamilyAvatar), findsNothing);
  });

  testWidgets('shows the family avatar for a whole-family event', (
    tester,
  ) async {
    await pumpCard(
      tester,
      Event(id: '1', title: 'Bins out', startsAt: DateTime(2026, 10, 26, 6)),
    );

    expect(find.byType(FamilyAvatar), findsOneWidget);
    expect(find.byType(MemberAvatar), findsNothing);
  });

  testWidgets('shows no end time for an all-day event', (tester) async {
    await pumpCard(
      tester,
      Event(
        id: '1',
        title: 'Birthday',
        startsAt: DateTime(2026, 10, 26),
        allDay: true,
        duration: const Duration(days: 1),
      ),
    );

    expect(find.textContaining('until '), findsNothing);
  });
}
