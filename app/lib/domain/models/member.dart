import 'package:flutter/foundation.dart';

@immutable
class Member {
  const Member({required this.id, required this.displayName, this.colour});

  final String id;
  final String displayName;

  /// Hex colour such as `#3B82F6`, or null if none is set.
  final String? colour;

  factory Member.fromJson(Map<String, dynamic> json) {
    return Member(
      id: json['id'] as String,
      displayName: json['display_name'] as String,
      colour: json['colour'] as String?,
    );
  }
}
