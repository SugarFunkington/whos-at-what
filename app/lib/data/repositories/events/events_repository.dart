import 'package:app/domain/models/event.dart';
import 'package:app/utils/result.dart';

abstract class EventsRepository {
  Future<Result<List<Event>>> fetchTodaysEvents();
}
