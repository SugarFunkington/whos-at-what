import 'package:app/domain/models/event.dart';
import 'package:app/domain/models/member.dart';
import 'package:app/ui/home/view_models/home_viewmodel.dart';
import 'package:app/utils/result.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../testing/fakes/repositories/fake_events_repository.dart';
import '../../../../testing/fakes/repositories/fake_members_repository.dart';

void main() {
  final event = Event(
    id: '1',
    title: 'Swimming',
    startsAt: DateTime(2026, 10, 5, 9),
  );

  const parent = Member(id: 'parent', displayName: 'Parent');
  const ella = Member(id: 'ella', displayName: 'Ella');
  const jack = Member(id: 'jack', displayName: 'Jack');
  final membersRepository = FakeMembersRepository(
    result: const Result.ok([parent, ella, jack]),
  );

  HomeViewModel viewModelWith(List<Event> events) => HomeViewModel(
    eventsRepository: FakeEventsRepository(result: Result.ok(events)),
    membersRepository: membersRepository,
  );

  test('loads events and members when created', () async {
    final viewModel = viewModelWith([event]);
    expect(viewModel.load.running, isTrue);

    await pumpEventQueue();

    expect(viewModel.load.completed, isTrue);
    expect(viewModel.events, [event]);
    expect(viewModel.members, [parent, ella, jack]);
  });

  test('loads the events for its day', () async {
    final eventsRepository = FakeEventsRepository();
    HomeViewModel(
      eventsRepository: eventsRepository,
      membersRepository: FakeMembersRepository(),
      today: DateTime(2026, 10, 26),
    );

    await pumpEventQueue();

    expect(eventsRepository.lastDay, DateTime(2026, 10, 26));
  });

  test('load errors when the events repository fails', () async {
    final viewModel = HomeViewModel(
      eventsRepository: FakeEventsRepository(
        result: Result.error(Exception('connection refused')),
      ),
      membersRepository: FakeMembersRepository(),
    );

    await pumpEventQueue();

    expect(viewModel.load.error, isTrue);
    expect(viewModel.events, isEmpty);
  });

  test('load errors when the members repository fails', () async {
    final viewModel = HomeViewModel(
      eventsRepository: FakeEventsRepository(),
      membersRepository: FakeMembersRepository(
        result: Result.error(Exception('connection refused')),
      ),
    );

    await pumpEventQueue();

    expect(viewModel.load.error, isTrue);
    expect(viewModel.members, isEmpty);
  });

  test('sorts all-day events to the top, keeping time order', () async {
    final bins = Event(
      id: '1',
      title: 'Bins out',
      startsAt: DateTime(2026, 10, 5, 6),
    );
    final birthday = Event(
      id: '2',
      title: 'Birthday',
      startsAt: DateTime(2026, 10, 5),
      allDay: true,
    );
    final swimming = Event(
      id: '3',
      title: 'Swimming',
      startsAt: DateTime(2026, 10, 5, 16),
    );
    final viewModel = viewModelWith([bins, birthday, swimming]);

    await pumpEventQueue();

    expect(viewModel.events, [birthday, bins, swimming]);
  });

  test('membersFor is the event\'s members, in family order', () async {
    final hurling = Event(
      id: '1',
      title: 'Hurling',
      startsAt: DateTime(2026, 10, 5, 18),
      memberIds: ['jack', 'parent'],
    );
    final viewModel = viewModelWith([hurling]);

    await pumpEventQueue();

    expect(viewModel.membersFor(hurling), [parent, jack]);
  });

  group('membersOnToday', () {
    test('is the members on any of today\'s events, in family order', () async {
      final viewModel = viewModelWith([
        Event(
          id: '1',
          title: 'Hurling',
          startsAt: DateTime(2026, 10, 5, 18),
          memberIds: ['jack', 'parent'],
        ),
        Event(
          id: '2',
          title: 'Swimming',
          startsAt: DateTime(2026, 10, 5, 16),
          memberIds: ['parent'],
        ),
      ]);

      await pumpEventQueue();

      expect(viewModel.membersOnToday, [parent, jack]);
    });

    test('is everyone when there is a whole-family event', () async {
      final viewModel = viewModelWith([
        Event(
          id: '1',
          title: 'Swimming',
          startsAt: DateTime(2026, 10, 5, 16),
          memberIds: ['ella'],
        ),
        Event(id: '2', title: 'Bins out', startsAt: DateTime(2026, 10, 5, 6)),
      ]);

      await pumpEventQueue();

      expect(viewModel.membersOnToday, [parent, ella, jack]);
    });

    test('is nobody when nothing is on', () async {
      final viewModel = viewModelWith([]);

      await pumpEventQueue();

      expect(viewModel.membersOnToday, isEmpty);
    });
  });
}
