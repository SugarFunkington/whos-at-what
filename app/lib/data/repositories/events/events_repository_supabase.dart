import 'package:app/data/repositories/events/events_repository.dart';
import 'package:app/domain/models/event.dart';
import 'package:app/utils/result.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class EventsRepositorySupabase implements EventsRepository {
  EventsRepositorySupabase(this._client);

  final SupabaseClient _client;

  @override
  Future<Result<List<Event>>> fetchTodaysEvents() async {
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, now.day);
    final end = DateTime(now.year, now.month, now.day + 1);

    try {
      final rows = await _client
          .from('events')
          .select('id, title, starts_at')
          .gte('starts_at', start.toUtc().toIso8601String())
          .lt('starts_at', end.toUtc().toIso8601String())
          .order('starts_at', ascending: true);

      return Result.ok(rows.map(Event.fromJson).toList());
    } on Exception catch (error) {
      return Result.error(error);
    }
  }
}
