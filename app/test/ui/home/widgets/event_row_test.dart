import 'package:app/domain/models/event.dart';
import 'package:app/domain/models/member.dart';
import 'package:app/ui/core/member_avatar.dart';
import 'package:app/ui/home/widgets/event_row.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const parent = Member(id: 'parent', displayName: 'Parent');
  const ella = Member(id: 'ella', displayName: 'Ella');

  Future<void> pumpRow(
    WidgetTester tester,
    Event event, {
    List<Member> members = const [],
  }) {
    return tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: EventRow(event: event, members: members),
        ),
      ),
    );
  }

  testWidgets('shows the time, emoji, title and location', (tester) async {
    await pumpRow(
      tester,
      Event(
        id: '1',
        title: 'Swimming',
        startsAt: DateTime(2026, 10, 26, 8, 30),
        emoji: '🏊',
        location: 'Leisure Centre',
        memberIds: ['ella'],
      ),
      members: [ella],
    );

    expect(find.text('08:30'), findsOneWidget);
    expect(find.text('🏊 Swimming'), findsOneWidget);
    expect(find.text('Leisure Centre'), findsOneWidget);
  });

  testWidgets('shows just the title without an emoji or location', (
    tester,
  ) async {
    await pumpRow(
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
    expect(texts, ['10:00', 'Football', 'E']);
  });

  testWidgets('shows an avatar for each member', (tester) async {
    await pumpRow(
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
    await pumpRow(
      tester,
      Event(id: '1', title: 'Bins out', startsAt: DateTime(2026, 10, 26, 6)),
    );

    expect(find.byType(FamilyAvatar), findsOneWidget);
    expect(find.byType(MemberAvatar), findsNothing);
  });

  testWidgets('shows "All day" instead of a time', (tester) async {
    await pumpRow(
      tester,
      Event(
        id: '1',
        title: 'Birthday',
        startsAt: DateTime(2026, 10, 26),
        allDay: true,
      ),
    );

    expect(find.text('All day'), findsOneWidget);
    expect(find.text('00:00'), findsNothing);
  });
}
