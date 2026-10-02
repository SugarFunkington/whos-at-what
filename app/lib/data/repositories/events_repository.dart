import 'package:app/domain/models/event.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class EventsRepository {
  EventsRepository(this._client);

  final SupabaseClient _client;

  Future<List<Event>> fetchToday() async {
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, now.day);
    final end = DateTime(now.year, now.month, now.day + 1);

    final rows = await _client
        .from('events')
        .select('id, title, starts_at')
        .gte('starts_at', start.toUtc().toIso8601String())
        .lt('starts_at', end.toUtc().toIso8601String())
        .order('starts_at', ascending: true);

    return rows.map(Event.fromJson).toList();
  }
}
