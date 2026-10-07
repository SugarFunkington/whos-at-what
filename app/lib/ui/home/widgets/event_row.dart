import 'package:app/domain/models/event.dart';
import 'package:app/domain/models/member.dart';
import 'package:app/ui/core/date_format_time.dart';
import 'package:app/ui/core/member_avatar.dart';
import 'package:app/ui/core/member_avatar_stack.dart';
import 'package:flutter/material.dart';

/// One event on the home day view: time on the left, then emoji + title,
/// location, and who it's for.
class EventRow extends StatelessWidget {
  const EventRow({super.key, required this.event, required this.members});

  final Event event;

  /// The members [event] is for. Ignored for a whole-family event.
  final List<Member> members;

  static const _timeColumnWidth = 64.0;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final emoji = event.emoji;
    final location = event.location;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          SizedBox(
            width: _timeColumnWidth,
            child: Text(
              event.allDay ? 'All day' : dateFormatTime(event.startsAt),
              style: textTheme.titleSmall,
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  emoji == null ? event.title : '$emoji ${event.title}',
                  style: textTheme.titleMedium,
                ),
                if (location != null)
                  Text(location, style: textTheme.bodyMedium),
              ],
            ),
          ),
          event.isWholeFamily
              ? const FamilyAvatar()
              : MemberAvatarStack(members: members),
        ],
      ),
    );
  }
}
