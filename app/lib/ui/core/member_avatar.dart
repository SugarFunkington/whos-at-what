import 'package:app/domain/models/member.dart';
import 'package:app/ui/core/member_colours.dart';
import 'package:flutter/material.dart';

/// The avatar sizes in the design.
enum AvatarSize {
  large(diameter: 36, overlap: 9, ring: 2),
  small(diameter: 24, overlap: 6, ring: 1.5);

  const AvatarSize({
    required this.diameter,
    required this.overlap,
    required this.ring,
  });

  final double diameter;

  /// How far each avatar in a stack covers the one before it.
  final double overlap;

  /// Width of the coloured ring.
  final double ring;
}

/// A ring in the member's colour, filled with a tint of it, with the start of
/// their first name.
class MemberAvatar extends StatelessWidget {
  const MemberAvatar({super.key, required this.member, required this.size});

  final Member member;
  final AvatarSize size;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colour = parseHex(member.colour) ?? theme.colorScheme.primary;
    final letterStyle = switch (size) {
      AvatarSize.large => theme.textTheme.labelLarge,
      AvatarSize.small => theme.textTheme.labelSmall,
    };

    return Semantics(
      label: member.displayName,
      excludeSemantics: true,
      child: _AvatarCircle(
        size: size,
        colour: colour,
        child: Text(
          _displayLetter(member.displayName),
          style: letterStyle?.copyWith(color: theme.colorScheme.onSurface),
        ),
      ),
    );
  }
}

/// Stands in for everyone on a whole-family event.
class FamilyAvatar extends StatelessWidget {
  const FamilyAvatar({super.key, required this.size});

  final AvatarSize size;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Semantics(
      label: 'Whole family',
      excludeSemantics: true,
      child: _AvatarCircle(
        size: size,
        colour: colorScheme.tertiary,
        child: Icon(
          Icons.groups,
          size: size.diameter / 2,
          color: colorScheme.onSurface,
        ),
      ),
    );
  }
}

/// The circle both avatars share: a [colour] ring, a tint of it inside, and a
/// small shadow.
class _AvatarCircle extends StatelessWidget {
  const _AvatarCircle({
    required this.size,
    required this.colour,
    required this.child,
  });

  final AvatarSize size;
  final Color colour;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final shadow = Theme.of(context).colorScheme.shadow;
    return Container(
      width: size.diameter,
      height: size.diameter,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: tint(colour),
        border: Border.all(color: colour, width: size.ring),
        boxShadow: [
          BoxShadow(
            color: shadow.withValues(alpha: 0.2),
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: child,
    );
  }
}

String _displayLetter(String displayName) =>
    displayName.trim().split(' ')[0].characters.take(1).toString();
