import 'package:app/domain/models/event.dart';
import 'package:app/domain/models/member.dart';
import 'package:app/ui/core/member_avatar.dart';
import 'package:app/ui/home/view_models/home_viewmodel.dart';
import 'package:app/ui/home/widgets/event_row.dart';
import 'package:app/ui/home/widgets/home_screen.dart';
import 'package:app/utils/result.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../testing/fakes/repositories/fake_events_repository.dart';
import '../../../../testing/fakes/repositories/fake_members_repository.dart';

void main() {
  testWidgets('app bar shows the date', (tester) async {
    final viewModel = HomeViewModel(
      eventsRepository: FakeEventsRepository(),
      membersRepository: FakeMembersRepository(),
      today: DateTime(2026, 10, 26),
    );
    await tester.pumpWidget(
      MaterialApp(home: HomeScreen(viewModel: viewModel)),
    );
    await tester.pumpAndSettle();
    expect(find.text('Monday, 26th October'), findsOneWidget);
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

  testWidgets('app bar shows the members with something on today', (
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

    Finder inAppBar(Finder finder) =>
        find.descendant(of: find.byType(AppBar), matching: finder);
    expect(inAppBar(find.byType(MemberAvatar)), findsOneWidget);
    expect(inAppBar(find.text('E')), findsOneWidget);
    expect(inAppBar(find.text('P')), findsNothing);
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

    expect(find.byType(EventRow), findsNWidgets(2));
  });
}
