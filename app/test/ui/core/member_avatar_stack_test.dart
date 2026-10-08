import 'package:app/domain/models/member.dart';
import 'package:app/ui/core/member_avatar.dart';
import 'package:app/ui/core/member_avatar_stack.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Future<void> pumpStack(WidgetTester tester, List<Member> members) {
    return tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: MemberAvatarStack(members: members, size: AvatarSize.small),
          ),
        ),
      ),
    );
  }

  testWidgets('each avatar overlaps the one before it', (tester) async {
    await pumpStack(tester, const [
      Member(id: '1', displayName: 'Ella'),
      Member(id: '2', displayName: 'Parent'),
    ]);

    final first = tester.getTopLeft(find.byType(MemberAvatar).first);
    final second = tester.getTopLeft(find.byType(MemberAvatar).last);
    expect(
      (second.dx - first.dx),
      (AvatarSize.small.diameter - AvatarSize.small.overlap),
    );
  });

  testWidgets('shows nothing without members', (tester) async {
    await pumpStack(tester, const []);

    expect(find.byType(MemberAvatar), findsNothing);
  });
}
