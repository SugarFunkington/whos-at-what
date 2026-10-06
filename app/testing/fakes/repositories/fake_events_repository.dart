import 'package:app/data/repositories/events/events_repository.dart';
import 'package:app/domain/models/event.dart';
import 'package:app/utils/result.dart';

class FakeEventsRepository implements EventsRepository {
  FakeEventsRepository({this.result = const Result.ok([])});

  final Result<List<Event>> result;

  int fetchCount = 0;
  DateTime? lastDay;

  @override
  Future<Result<List<Event>>> fetchEvents(DateTime day) async {
    fetchCount++;
    lastDay = day;
    return result;
  }
}
