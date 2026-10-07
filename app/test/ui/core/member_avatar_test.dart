import 'package:app/domain/models/member.dart';
import 'package:app/ui/core/member_avatar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Future<void> pumpAvatar(WidgetTester tester, Member member) {
    return tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: MemberAvatar(member: member)),
      ),
    );
  }

  CircleAvatar circle(WidgetTester tester) =>
      tester.widget<CircleAvatar>(find.byType(CircleAvatar));

  testWidgets('shows the first letter of the first name', (tester) async {
    await pumpAvatar(
      tester,
      const Member(id: '1', displayName: 'Mary Kate', colour: '#EC4899'),
    );

    expect(find.text('M'), findsOneWidget);
  });

  testWidgets('uses the member colour as the background', (tester) async {
    await pumpAvatar(
      tester,
      const Member(id: '1', displayName: 'Ella', colour: '#EC4899'),
    );

    expect(circle(tester).backgroundColor, const Color(0xFFEC4899));
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
      circle(tester).backgroundColor,
      Theme.of(context).colorScheme.primaryContainer,
    );
  });

  testWidgets('picks readable text for the background', (tester) async {
    await pumpAvatar(
      tester,
      const Member(id: '1', displayName: 'Ella', colour: '#1E3A8A'),
    );
    expect(circle(tester).foregroundColor, Colors.white);

    await pumpAvatar(
      tester,
      const Member(id: '1', displayName: 'Ella', colour: '#FDE047'),
    );
    expect(circle(tester).foregroundColor, Colors.black);
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
      const MaterialApp(home: Scaffold(body: FamilyAvatar())),
    );

    expect(find.byIcon(Icons.groups), findsOneWidget);
    expect(find.bySemanticsLabel('Whole family'), findsOneWidget);
    semantics.dispose();
  });
}
