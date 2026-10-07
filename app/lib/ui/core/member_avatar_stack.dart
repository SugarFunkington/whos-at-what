import 'package:app/domain/models/member.dart';
import 'package:app/ui/core/member_avatar.dart';
import 'package:flutter/material.dart';

/// Member avatars overlapping left to right, each with a ring in the
/// background colour so the edges stay visible.
class MemberAvatarStack extends StatelessWidget {
  const MemberAvatarStack({super.key, required this.members});

  final List<Member> members;

  static const _ring = 2.0;
  static const _size = (MemberAvatar.radius + _ring) * 2;
  static const _step = _size * 0.6;

  @override
  Widget build(BuildContext context) {
    if (members.isEmpty) return const SizedBox.shrink();

    final ringColour = Theme.of(context).colorScheme.surface;
    return SizedBox(
      width: _step * (members.length - 1) + _size,
      height: _size,
      child: Stack(
        children: [
          for (final (index, member) in members.indexed)
            Positioned(
              left: index * _step,
              child: CircleAvatar(
                radius: MemberAvatar.radius + _ring,
                backgroundColor: ringColour,
                child: MemberAvatar(member: member),
              ),
            ),
        ],
      ),
    );
  }
}
