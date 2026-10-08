import 'package:app/domain/models/member.dart';
import 'package:app/ui/core/member_avatar.dart';
import 'package:app/ui/core/member_colours.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Future<void> pumpAvatar(WidgetTester tester, Member member) {
    return tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: MemberAvatar(member: member, size: AvatarSize.large),
        ),
      ),
    );
  }

  BoxDecoration circle(WidgetTester tester) {
    final container = tester.widget<Container>(
      find.descendant(
        of: find.byType(MemberAvatar),
        matching: find.byType(Container),
      ),
    );
    return container.decoration! as BoxDecoration;
  }

  testWidgets('shows the first letter of the first name', (tester) async {
    await pumpAvatar(
      tester,
      const Member(id: '1', displayName: 'Mary Kate', colour: '#EC4899'),
    );

    expect(find.text('M'), findsOneWidget);
  });

  testWidgets('rings the member colour around a tint of it', (tester) async {
    await pumpAvatar(
      tester,
      const Member(id: '1', displayName: 'Ella', colour: '#EC4899'),
    );

    const pink = Color(0xFFEC4899);
    expect((circle(tester).border! as Border).top.color, pink);
    expect(circle(tester).color, tint(pink));
  });

  testWidgets('falls back to the theme colour for a bad colour', (
    tester,
  ) async {
    await pumpAvatar(
      tester,
      const Member(id: '1', displayName: 'Ella', colour: 'pink'),
    );

    final context = tester.element(find.byType(MemberAvatar));
    expect(
      (circle(tester).border! as Border).top.color,
      Theme.of(context).colorScheme.primary,
    );
  });

  testWidgets('sizes the circle from the avatar size', (tester) async {
    await pumpAvatar(tester, const Member(id: '1', displayName: 'Ella'));

    expect(tester.getSize(find.byType(MemberAvatar)), const Size(36, 36));
  });

  testWidgets('screen readers hear the full name', (tester) async {
    final semantics = tester.ensureSemantics();
    await pumpAvatar(tester, const Member(id: '1', displayName: 'Ella'));

    expect(find.bySemanticsLabel('Ella'), findsOneWidget);
    expect(find.bySemanticsLabel('Ell'), findsNothing);
    semantics.dispose();
  });

  testWidgets('family avatar is read as the whole family', (tester) async {
    final semantics = tester.ensureSemantics();
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: FamilyAvatar(size: AvatarSize.small)),
      ),
    );

    expect(find.byIcon(Icons.groups), findsOneWidget);
    expect(find.bySemanticsLabel('Whole family'), findsOneWidget);
    semantics.dispose();
  });
}
