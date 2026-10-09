import 'package:app/domain/models/event.dart';
import 'package:app/domain/models/member.dart';
import 'package:app/ui/core/date_format_time.dart';
import 'package:app/ui/core/member_avatar.dart';
import 'package:app/ui/core/member_avatar_stack.dart';
import 'package:app/ui/core/member_colours.dart';
import 'package:app/ui/core/themes/dimens.dart';
import 'package:flutter/material.dart';

/// The colour that marks [event]: its first member's (the avatar stack starts
/// with them), or the whole-family colour.
Color eventColour(ColorScheme colorScheme, Event event, List<Member> members) {
  if (event.isWholeFamily) return colorScheme.tertiary;
  return parseHex(members.firstOrNull?.colour) ?? colorScheme.primary;
}

/// One event on the home timeline: emoji tile, title, end time and place, who
/// it's for, and its notes.
class EventCard extends StatelessWidget {
  const EventCard({super.key, required this.event, required this.members});

  final Event event;

  /// The members [event] is for. Ignored for a whole-family event.
  final List<Member> members;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final emoji = event.emoji;
    final notes = event.notes;
    final duration = event.duration;
    final details = [
      if (!event.allDay && duration != null)
        'to ${dateFormatTime(event.startsAt.add(duration))}',
      ?event.location,
    ].join(' · ');

    return Container(
      padding: const EdgeInsets.all(Dimens.md),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(Dimens.radiusCard),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (emoji != null) ...[
                _EmojiTile(
                  emoji: emoji,
                  colour: event.isWholeFamily
                      ? theme.colorScheme.tertiaryContainer
                      : tint(eventColour(theme.colorScheme, event, members)),
                ),
                const SizedBox(width: Dimens.md),
              ],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(event.title, style: theme.textTheme.titleSmall),
                    if (details.isNotEmpty)
                      Text(details, style: theme.textTheme.bodySmall),
                  ],
                ),
              ),
              const SizedBox(width: Dimens.sm),
              event.isWholeFamily
                  ? const FamilyAvatar(size: AvatarSize.small)
                  : MemberAvatarStack(members: members, size: AvatarSize.small),
            ],
          ),
          if (notes != null) ...[
            const SizedBox(height: Dimens.sm),
            // Display only. shrinkWrap drops the extra space Material adds
            // around tappable things.
            Chip(
              label: Text(notes),
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
          ],
        ],
      ),
    );
  }
}

class _EmojiTile extends StatelessWidget {
  const _EmojiTile({required this.emoji, required this.colour});

  final String emoji;
  final Color colour;

  static const _size = 42.0;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: _size,
      height: _size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: colour,
        borderRadius: BorderRadius.circular(Dimens.radiusTile),
      ),
      child: Text(emoji, style: Theme.of(context).textTheme.titleLarge),
    );
  }
}
