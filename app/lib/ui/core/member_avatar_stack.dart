import 'package:app/domain/models/member.dart';
import 'package:app/ui/core/member_avatar.dart';
import 'package:app/ui/core/themes/dimens.dart';
import 'package:flutter/material.dart';

/// Member avatars overlapping left to right, on a light see-through pill.
class MemberAvatarStack extends StatelessWidget {
  const MemberAvatarStack({
    super.key,
    required this.members,
    required this.size,
  });

  final List<Member> members;
  final AvatarSize size;

  @override
  Widget build(BuildContext context) {
    if (members.isEmpty) return const SizedBox.shrink();

    final step = size.diameter - size.overlap;
    final pillColour = Theme.of(context).colorScheme.surface
        .withValues(alpha: 0.5);
    return Container(
      padding: const EdgeInsets.all(Dimens.xs),
      decoration: BoxDecoration(
        color: pillColour,
        borderRadius: BorderRadius.circular(Dimens.radiusPill),
      ),
      child: SizedBox(
        width: step * (members.length - 1) + size.diameter,
        height: size.diameter,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            for (final (index, member) in members.indexed)
              Positioned(
                left: index * step,
                child: MemberAvatar(member: member, size: size),
              ),
          ],
        ),
      ),
    );
  }
}
