import 'package:app/domain/models/event.dart';
import 'package:app/domain/models/member.dart';
import 'package:app/ui/core/date_format_time.dart';
import 'package:app/ui/core/event_colour.dart';
import 'package:app/ui/core/themes/dimens.dart';
import 'package:app/ui/home/widgets/event_card.dart';
import 'package:flutter/material.dart';

/// The events that start at one time: the time, a dot per event on the
/// timeline's line, and their cards.
class TimeSlot extends StatelessWidget {
  const TimeSlot({
    super.key,
    required this.events,
    required this.membersFor,
    this.isFirst = false,
    this.isLast = false,
  });

  /// Events that all start at the same time, or are all all-day.
  final List<Event> events;

  /// Gives the members an event is for.
  final List<Member> Function(Event event) membersFor;

  /// The line starts at the first slot's dots and stops at the last one's.
  final bool isFirst;
  final bool isLast;

  /// Wide enough for "All day".
  static const _timeColumnWidth = 54.0;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final first = events.first;

    // IntrinsicHeight makes the row as tall as its tallest child, the cards,
    // so the line can stretch the full height and join the next slot's.
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: _timeColumnWidth,
            child: Padding(
              padding: const EdgeInsets.only(top: Dimens.md),
              // Right-aligned, so every time sits the same distance from the
              // line. Align lets its child shrink to its own width instead of
              // filling the time column.
              child: Align(
                alignment: Alignment.topRight,
                child: first.allDay
                    ? Text('All day', style: theme.textTheme.titleSmall)
                    // The clock, with a small AM/PM under it.
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            dateFormatClock(first.startsAt),
                            style: theme.textTheme.titleSmall,
                          ),
                          Text(
                            dateFormatPeriod(first.startsAt),
                            style: theme.textTheme.bodySmall,
                          ),
                        ],
                      ),
              ),
            ),
          ),
          _TimelineMarker(
            colours: [
              for (final event in events)
                eventColour(theme.colorScheme, event, membersFor(event)),
            ],
            isFirst: isFirst,
            isLast: isLast,
          ),
          Expanded(
            child: Column(
              children: [
                for (final event in events)
                  Padding(
                    key: ValueKey(event.id),
                    padding: const EdgeInsets.only(bottom: Dimens.md),
                    child: EventCard(event: event, members: membersFor(event)),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// The timeline's vertical line with a dot per event, each dot slightly
/// overlapping the one above.
class _TimelineMarker extends StatelessWidget {
  const _TimelineMarker({
    required this.colours,
    required this.isFirst,
    required this.isLast,
  });

  final List<Color> colours;
  final bool isFirst;
  final bool isLast;

  static const _lineWidth = 2.0;

  /// Puts the first dot's centre level with the time beside it.
  static const _dotTop = 15.0;

  @override
  Widget build(BuildContext context) {
    final lineColour = Theme.of(context).colorScheme.outline;
    const step = TimelineDot.size - TimelineDot.overlap;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: Dimens.sm),
      child: Column(
        children: [
          // A Container with no colour draws nothing but still takes space.
          Container(
            width: _lineWidth,
            height: _dotTop,
            color: isFirst ? null : lineColour,
          ),
          SizedBox(
            width: TimelineDot.size,
            height: step * (colours.length - 1) + TimelineDot.size,
            child: Stack(
              children: [
                for (final (index, colour) in colours.indexed)
                  Positioned(
                    top: index * step,
                    child: TimelineDot(colour: colour),
                  ),
              ],
            ),
          ),
          Expanded(
            child: Container(
              width: _lineWidth,
              color: isLast ? null : lineColour,
            ),
          ),
        ],
      ),
    );
  }
}

/// A 14px dot in an event's colour, with a light shadow so overlapping dots
/// stay distinct.
class TimelineDot extends StatelessWidget {
  const TimelineDot({super.key, required this.colour});

  final Color colour;

  static const size = 14.0;

  /// How far each dot in a stack covers the one above.
  static const overlap = 6.0;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: colour,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.shadow.withValues(alpha: 0.2),
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
      ),
    );
  }
}
