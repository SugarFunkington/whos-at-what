import 'package:flutter/material.dart';

/// `#RRGGBB` as an opaque colour, or null if [hex] isn't in that format.
Color? parseHex(String? hex) {
  if (hex == null || !RegExp(r'^#[0-9a-fA-F]{6}$').hasMatch(hex)) return null;
  return Color(0xFF000000 | int.parse(hex.substring(1), radix: 16));
}

/// A light tint of [colour]: blended 80% of the way to white.
Color tint(Color color) => Color.lerp(color, Colors.white, 0.8)!;
