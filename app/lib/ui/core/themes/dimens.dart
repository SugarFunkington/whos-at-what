import 'package:flutter/widgets.dart';

abstract final class Dimens {
  // Spacing between items.
  static const xs = 4.0;
  static const sm = 8.0;
  static const md = 12.0;
  static const lg = 16.0;
  static const xl = 20.0;
  static const section = 28.0;

  /// Padding between the screen edge and its content.
  static const screenPadding = 18.0;
  static const edgeInsetsScreen = EdgeInsets.all(screenPadding);

  // Corner radii.
  static const radiusItemTile = 13.0;
  static const radiusTile = 14.0;
  static const radiusCard = 20.0;
  static const radiusSurface = 28.0;
  static const radiusBlock = 36.0;
  static const radiusPill = 999.0;
}
