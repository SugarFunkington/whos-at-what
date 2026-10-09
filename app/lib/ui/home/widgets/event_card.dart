import 'package:app/domain/models/event.dart';
import 'package:app/domain/models/member.dart';
import 'package:app/ui/core/date_format_time.dart';
import 'package:app/ui/core/event_colour.dart';
import 'package:app/ui/core/member_avatar.dart';
import 'package:app/ui/core/member_avatar_stack.dart';
import 'package:app/ui/core/member_colours.dart';
import 'package:app/ui/core/themes/dimens.dart';
import 'package:flutter/material.dart';

/// One event on the home timeline: emoji tile, title, end time, place, who
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
    final location = event.location;

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
                    if (!event.allDay && duration != null)
                      _Detail(
                        icon: Icons.schedule_outlined,
                        text:
                            'until ${dateFormatTime(event.startsAt.add(duration))}',
                      ),
                    if (location != null)
                      _Detail(icon: Icons.location_on_outlined, text: location),
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

/// A small muted line under the title: an icon, then [text].
class _Detail extends StatelessWidget {
  const _Detail({required this.icon, required this.text});

  final IconData icon;
  final String text;

  static const _iconSize = 13.0;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // Top-aligned, so a wrapped place keeps its icon by the first line.
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          // Centres the icon on the first line of text.
          padding: const EdgeInsets.only(top: 1.5),
          child: Icon(
            icon,
            size: _iconSize,
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(width: Dimens.xs),
        // Flexible lets a long place wrap instead of overflowing the card.
        Flexible(child: Text(text, style: theme.textTheme.bodySmall)),
      ],
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
