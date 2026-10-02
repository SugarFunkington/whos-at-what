import 'package:flutter/foundation.dart';

@immutable
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
