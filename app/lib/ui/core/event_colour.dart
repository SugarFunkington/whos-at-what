import 'package:app/domain/models/event.dart';
import 'package:app/domain/models/member.dart';
import 'package:app/ui/core/member_colours.dart';
import 'package:flutter/material.dart';

/// The colour that marks [event]: its first member's (the avatar stack starts
/// with them), or the whole-family colour.
Color eventColour(ColorScheme colorScheme, Event event, List<Member> members) {
  if (event.isWholeFamily) return colorScheme.tertiary;
  return parseHex(members.firstOrNull?.colour) ?? colorScheme.primary;
}
