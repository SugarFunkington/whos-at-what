import 'package:app/domain/models/event.dart';
import 'package:app/ui/home/view_models/home_viewmodel.dart';
import 'package:app/utils/result.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../testing/fakes/repositories/fake_events_repository.dart';

void main() {
  final event = Event(
    id: '1',
    title: 'Swimming',
    startsAt: DateTime(2026, 10, 5, 9),
  );

  test('loads events when created', () async {
    final viewModel = HomeViewModel(
      eventsRepository: FakeEventsRepository(result: Result.ok([event])),
    );
    expect(viewModel.load.running, isTrue);

    await pumpEventQueue();

    expect(viewModel.load.completed, isTrue);
    expect(viewModel.events, [event]);
  });

  test('loads the events for its day', () async {
    final eventsRepository = FakeEventsRepository();
    HomeViewModel(
      eventsRepository: eventsRepository,
      today: DateTime(2026, 10, 26),
    );

    await pumpEventQueue();

    expect(eventsRepository.lastDay, DateTime(2026, 10, 26));
  });

  test('load errors when the repository fails', () async {
    final viewModel = HomeViewModel(
      eventsRepository: FakeEventsRepository(
        result: Result.error(Exception('connection refused')),
      ),
    );

    await pumpEventQueue();

    expect(viewModel.load.error, isTrue);
    expect(viewModel.events, isEmpty);
  });
}
