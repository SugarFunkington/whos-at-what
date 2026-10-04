import 'package:app/data/repositories/events/events_repository.dart';
import 'package:app/domain/models/event.dart';
import 'package:app/utils/result.dart';

class FakeEventsRepository implements EventsRepository {
  FakeEventsRepository({this.result = const Result.ok([])});

  final Result<List<Event>> result;

  @override
  Future<Result<List<Event>>> fetchTodaysEvents() async => result;
}
