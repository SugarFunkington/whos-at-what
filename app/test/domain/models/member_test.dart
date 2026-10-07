import 'package:app/domain/models/member.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('fromJson reads a member', () {
    final member = Member.fromJson({
      'id': '1',
      'display_name': 'Ella',
      'colour': '#EC4899',
    });

    expect(member.id, '1');
    expect(member.displayName, 'Ella');
    expect(member.colour, '#EC4899');
  });

  test('fromJson allows no colour', () {
    final member = Member.fromJson({
      'id': '1',
      'display_name': 'Ella',
      'colour': null,
    });

    expect(member.colour, isNull);
  });
}
