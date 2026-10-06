import 'package:app/ui/home/view_models/home_viewmodel.dart';
import 'package:app/ui/home/widgets/home_screen.dart';
import 'package:app/utils/result.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../testing/fakes/repositories/fake_events_repository.dart';

void main() {
  testWidgets('failed load shows a friendly message, not the exception', (
    tester,
  ) async {
    final viewModel = HomeViewModel(
      eventsRepository: FakeEventsRepository(
        result: Result.error(Exception('PostgrestException secret text')),
      ),
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
          viewModel: HomeViewModel(eventsRepository: eventsRepository),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(FilledButton, 'Try again'));
    await tester.pumpAndSettle();

    expect(eventsRepository.fetchCount, 2);
  });
}
