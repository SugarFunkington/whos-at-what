import 'package:supabase_flutter/supabase_flutter.dart';

class Event {
  const Event({required this.id, required this.title, required this.startsAt});

  final String id;
  final String title;
  final DateTime startsAt;

  factory Event.fromJson(Map<String, dynamic> json) {
    return Event(
      id: json['id'] as String,
      title: json['title'] as String,
      startsAt: DateTime.parse(json['starts_at'] as String).toLocal(),
    );
  }
}

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
