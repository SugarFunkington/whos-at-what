import 'package:app/data/repositories/events/events_repository.dart';
import 'package:app/domain/models/event.dart';
import 'package:app/utils/command.dart';
import 'package:app/utils/result.dart';
import 'package:flutter/foundation.dart';

class HomeViewModel extends ChangeNotifier {
  HomeViewModel({required this._eventsRepository, DateTime? today})
    : today = today ?? DateTime.now() {
    load = Command<void>(_load)..execute();
  }

  final EventsRepository _eventsRepository;

  final DateTime today;

  late final Command<void> load;

  List<Event> _events = [];
  List<Event> get events => _events;

  Future<Result<void>> _load() async {
    final result = await _eventsRepository.fetchEvents(today);
    switch (result) {
      case Ok():
        _events = result.value;
        notifyListeners();
        return const Result.ok(null);
      case Error():
        debugPrint('Failed to load events: ${result.error}');
        return Result.error(result.error);
    }
  }
}
