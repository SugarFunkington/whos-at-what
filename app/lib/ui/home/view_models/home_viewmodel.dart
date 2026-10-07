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
    if (_events.any((event) => event.memberIds.isEmpty)) return _members;
    final ids = {for (final event in _events) ...event.memberIds};
    return _members.where((member) => ids.contains(member.id)).toList();
  }

  Future<Result<void>> _load() async {
    // Both requests run in parallel; `.wait` waits until both have finished.
    final (eventsResult, membersResult) = await (
      _eventsRepository.fetchEvents(today),
      _membersRepository.fetchMembers(),
    ).wait;

    switch (eventsResult) {
      case Ok():
        _events = eventsResult.value;
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
