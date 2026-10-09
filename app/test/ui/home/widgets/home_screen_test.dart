import 'package:app/domain/models/event.dart';
import 'package:app/domain/models/member.dart';
import 'package:app/ui/core/member_avatar.dart';
import 'package:app/ui/home/view_models/home_viewmodel.dart';
import 'package:app/ui/home/widgets/event_card.dart';
import 'package:app/ui/home/widgets/home_header.dart';
import 'package:app/ui/home/widgets/home_screen.dart';
import 'package:app/utils/result.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../testing/fakes/repositories/fake_events_repository.dart';
import '../../../../testing/fakes/repositories/fake_members_repository.dart';

void main() {
  testWidgets('header shows the weekday and date', (tester) async {
    final viewModel = HomeViewModel(
      eventsRepository: FakeEventsRepository(),
      membersRepository: FakeMembersRepository(),
      today: DateTime(2026, 10, 26),
    );
    await tester.pumpWidget(
      MaterialApp(home: HomeScreen(viewModel: viewModel)),
    );
    await tester.pumpAndSettle();
    Finder inHeader(Finder finder) =>
        find.descendant(of: find.byType(HomeHeader), matching: finder);
    expect(inHeader(find.text('Monday')), findsOneWidget);
    expect(inHeader(find.text('26th October')), findsOneWidget);
  });

  testWidgets('failed load shows a friendly message, not the exception', (
    tester,
  ) async {
    final viewModel = HomeViewModel(
      eventsRepository: FakeEventsRepository(
        result: Result.error(Exception('PostgrestException secret text')),
      ),
      membersRepository: FakeMembersRepository(),
    );
    await tester.pumpWidget(
      MaterialApp(home: HomeScreen(viewModel: viewModel)),
    );
    await tester.pumpAndSettle();
    expect(find.text("Couldn't load today's events."), findsOneWidget);
    expect(find.textContaining("PostgrestException"), findsNothing);
    expect(find.widgetWithText(FilledButton, 'Try again'), findsOneWidget);
    expect(find.byType(HomeHeader), findsOneWidget);
  });

  testWidgets('tapping Try again reloads the events', (tester) async {
    final eventsRepository = FakeEventsRepository(
      result: Result.error(Exception('connection refused')),
    );
    await tester.pumpWidget(
      MaterialApp(
        home: HomeScreen(
          viewModel: HomeViewModel(
            eventsRepository: eventsRepository,
            membersRepository: FakeMembersRepository(),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(FilledButton, 'Try again'));
    await tester.pumpAndSettle();

    expect(eventsRepository.fetchCount, 2);
  });

  testWidgets('header shows the members with something on today', (
    tester,
  ) async {
    final viewModel = HomeViewModel(
      eventsRepository: FakeEventsRepository(
        result: Result.ok([
          Event(
            id: '1',
            title: 'Swimming',
            startsAt: DateTime(2026, 10, 26, 16),
            memberIds: ['ella'],
          ),
        ]),
      ),
      membersRepository: FakeMembersRepository(
        result: const Result.ok([
          Member(id: 'parent', displayName: 'Parent'),
          Member(id: 'ella', displayName: 'Ella'),
        ]),
      ),
    );
    await tester.pumpWidget(
      MaterialApp(home: HomeScreen(viewModel: viewModel)),
    );
    await tester.pumpAndSettle();

    Finder inHeader(Finder finder) =>
        find.descendant(of: find.byType(HomeHeader), matching: finder);
    expect(inHeader(find.byType(MemberAvatar)), findsOneWidget);
    expect(inHeader(find.text('E')), findsOneWidget);
    expect(inHeader(find.text('P')), findsNothing);
  });

  testWidgets('shows a row for each event', (tester) async {
    final viewModel = HomeViewModel(
      eventsRepository: FakeEventsRepository(
        result: Result.ok([
          Event(
            id: '1',
            title: 'Bins out',
            startsAt: DateTime(2026, 10, 26, 6),
          ),
          Event(
            id: '2',
            title: 'Swimming',
            startsAt: DateTime(2026, 10, 26, 16),
          ),
        ]),
      ),
      membersRepository: FakeMembersRepository(),
    );
    await tester.pumpWidget(
      MaterialApp(home: HomeScreen(viewModel: viewModel)),
    );
    await tester.pumpAndSettle();

    expect(find.byType(EventCard), findsNWidgets(2));
  });

  testWidgets('heading shows how many events there are', (tester) async {
    final viewModel = HomeViewModel(
      eventsRepository: FakeEventsRepository(
        result: Result.ok([
          Event(
            id: '1',
            title: 'Bins out',
            startsAt: DateTime(2026, 10, 26, 6),
          ),
          Event(
            id: '2',
            title: 'Swimming',
            startsAt: DateTime(2026, 10, 26, 16),
          ),
        ]),
      ),
      membersRepository: FakeMembersRepository(),
    );
    await tester.pumpWidget(
      MaterialApp(home: HomeScreen(viewModel: viewModel)),
    );
    await tester.pumpAndSettle();

    expect(find.text("Today's schedule"), findsOneWidget);
    expect(find.text('2 events'), findsOneWidget);
  });

  testWidgets('heading says "1 event" for a single event', (tester) async {
    final viewModel = HomeViewModel(
      eventsRepository: FakeEventsRepository(
        result: Result.ok([
          Event(
            id: '1',
            title: 'Bins out',
            startsAt: DateTime(2026, 10, 26, 6),
          ),
        ]),
      ),
      membersRepository: FakeMembersRepository(),
    );
    await tester.pumpWidget(
      MaterialApp(home: HomeScreen(viewModel: viewModel)),
    );
    await tester.pumpAndSettle();

    expect(find.text('1 event'), findsOneWidget);
  });

  testWidgets('heading says "0 events" when nothing is on', (tester) async {
    final viewModel = HomeViewModel(
      eventsRepository: FakeEventsRepository(),
      membersRepository: FakeMembersRepository(),
    );
    await tester.pumpWidget(
      MaterialApp(home: HomeScreen(viewModel: viewModel)),
    );
    await tester.pumpAndSettle();

    expect(find.text('0 events'), findsOneWidget);
  });
}
