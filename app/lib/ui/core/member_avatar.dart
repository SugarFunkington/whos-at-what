import 'package:app/domain/models/member.dart';
import 'package:flutter/material.dart';

/// A circle in the member's colour with the start of their first name.
class MemberAvatar extends StatelessWidget {
  const MemberAvatar({super.key, required this.member});

  static const radius = 16.0;

  final Member member;

  @override
  Widget build(BuildContext context) {
    final background =
        _parseHex(member.colour) ??
        Theme.of(context).colorScheme.primaryContainer;
    final foreground =
        ThemeData.estimateBrightnessForColor(background) == Brightness.dark
        ? Colors.white
        : Colors.black;

    return Semantics(
      label: member.displayName,
      excludeSemantics: true,
      child: CircleAvatar(
        radius: radius,
        backgroundColor: background,
        foregroundColor: foreground,
        child: Text(
          _displayLetter(member.displayName),
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}

/// Stands in for everyone on a whole-family event.
class FamilyAvatar extends StatelessWidget {
  const FamilyAvatar({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Semantics(
      label: 'Whole family',
      excludeSemantics: true,
      child: CircleAvatar(
        radius: MemberAvatar.radius,
        backgroundColor: colorScheme.secondaryContainer,
        foregroundColor: colorScheme.onSecondaryContainer,
        child: const Icon(Icons.groups, size: 18),
      ),
    );
  }
}

String _displayLetter(String displayName) =>
    displayName.trim().split(' ')[0].characters.take(1).toString();

/// `#RRGGBB` as an opaque colour, or null if [hex] isn't in that format.
Color? _parseHex(String? hex) {
  if (hex == null || !RegExp(r'^#[0-9a-fA-F]{6}$').hasMatch(hex)) return null;
  return Color(0xFF000000 | int.parse(hex.substring(1), radix: 16));
}
