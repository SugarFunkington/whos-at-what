import 'package:app/data/repositories/events/events_repository.dart';
import 'package:app/data/repositories/members/members_repository.dart';
import 'package:app/domain/models/event.dart';
import 'package:app/domain/models/member.dart';
import 'package:app/utils/command.dart';
import 'package:app/utils/result.dart';
import 'package:flutter/foundation.dart';

class HomeViewModel extends ChangeNotifier {
  HomeViewModel({
    required this._eventsRepository,
    required this._membersRepository,
    DateTime? today,
  }) : today = today ?? DateTime.now() {
    load = Command<void>(_load)..execute();
  }

  final EventsRepository _eventsRepository;
  final MembersRepository _membersRepository;

  final DateTime today;

  late final Command<void> load;

  List<Event> _events = [];
  List<Event> get events => _events;

  List<Member> _members = [];
  List<Member> get members => _members;

  /// Members with something on today. A whole-family event (no members)
  /// counts as everyone.
  List<Member> get membersOnToday {
    if (_events.any((event) => event.isWholeFamily)) return _members;
    final ids = {for (final event in _events) ...event.memberIds};
    return _members.where((member) => ids.contains(member.id)).toList();
  }

  /// Today's events grouped by start time, in order. All-day events share
  /// one group.
  List<List<Event>> get timeSlots {
    final slots = <List<Event>>[];
    for (final event in _events) {
      final previous = slots.lastOrNull?.last;
      if (previous != null && _startTogether(previous, event)) {
        slots.last.add(event);
      } else {
        slots.add([event]);
      }
    }
    return slots;
  }

  static bool _startTogether(Event a, Event b) {
    if (a.allDay || b.allDay) return a.allDay && b.allDay;
    return a.startsAt == b.startsAt;
  }

  /// The members [event] is for, in family order. Empty for a whole-family
  /// event.
  List<Member> membersFor(Event event) {
    return _members
        .where((member) => event.memberIds.contains(member.id))
        .toList();
  }

  Future<Result<void>> _load() async {
    // Both requests run in parallel; `.wait` waits until both have finished.
    final (eventsResult, membersResult) = await (
      _eventsRepository.fetchEvents(today),
      _membersRepository.fetchMembers(),
    ).wait;

    switch (eventsResult) {
      case Ok():
        // All-day events first; otherwise keep the repository's time order.
        final events = eventsResult.value;
        _events = [
          ...events.where((event) => event.allDay),
          ...events.where((event) => !event.allDay),
        ];
      case Error():
        debugPrint('Failed to load events: ${eventsResult.error}');
        return Result.error(eventsResult.error);
    }

    switch (membersResult) {
      case Ok():
        _members = membersResult.value;
        notifyListeners();
        return const Result.ok(null);
      case Error():
        debugPrint('Failed to load members: ${membersResult.error}');
        return Result.error(membersResult.error);
    }
  }
}
