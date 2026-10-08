import 'package:app/ui/core/member_colours.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('parses #RRGGBB as an opaque colour', () {
    expect(parseHex('#EC4899'), const Color(0xFFEC4899));
  });

  test('returns null for anything else', () {
    expect(parseHex(null), isNull);
    expect(parseHex('pink'), isNull);
    expect(parseHex('#EC489'), isNull);
  });

  test('tint is much lighter than the colour', () {
    const colour = Color(0xFF137A6B);
    expect(
      tint(colour).computeLuminance(),
      greaterThan(colour.computeLuminance()),
    );
    expect(tint(colour), isNot(Colors.white));
  });
}
