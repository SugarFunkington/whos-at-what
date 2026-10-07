import 'package:flutter/foundation.dart';

@immutable
class Event {
  const Event({
    required this.id,
    required this.title,
    required this.startsAt,
    this.allDay = false,
    this.duration,
    this.location,
    this.emoji,
    this.memberIds = const [],
  });

  final String id;
  final String title;
  final DateTime startsAt;
  final bool allDay;
  final Duration? duration;
  final String? location;
  final String? emoji;

  /// Who the event is for. Empty = the whole family.
  final List<String> memberIds;

  bool get isWholeFamily => memberIds.isEmpty;

  factory Event.fromJson(Map<String, dynamic> json) {
    final duration = json['duration'] as String?;
    return Event(
      id: json['id'] as String,
      title: json['title'] as String,
      startsAt: DateTime.parse(json['starts_at'] as String).toLocal(),
      allDay: json['all_day'] as bool,
      duration: duration == null ? null : _parseInterval(duration),
      location: json['location'] as String?,
      emoji: json['emoji'] as String?,
      memberIds: [
        for (final row in json['event_members'] as List)
          row['member_id'] as String,
      ],
    );
  }
}

/// Parses a Postgres interval as PostgREST sends it: `01:30:00`, or with
/// days in front (`1 day 02:00:00`, `3 days 00:15:00`).
Duration _parseInterval(String text) {
  final parts = text.split(' ');
  final days = parts.length == 3 ? int.parse(parts[0]) : 0;
  final [hours, minutes, seconds] = parts.last
      .split(':')
      .map(int.parse)
      .toList();
  return Duration(days: days, hours: hours, minutes: minutes, seconds: seconds);
}
