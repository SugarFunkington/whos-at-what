import 'package:app/ui/core/date_format_day.dart';
import 'package:app/ui/core/member_avatar.dart';
import 'package:app/ui/core/member_avatar_stack.dart';
import 'package:app/ui/core/themes/dimens.dart';
import 'package:app/ui/home/view_models/home_viewmodel.dart';
import 'package:flutter/material.dart';

/// The block at the top of the home screen: today's date and who has
/// something on. It scrolls away with the events.
class HomeHeader extends StatelessWidget {
  const HomeHeader({super.key, required this.viewModel});

  final HomeViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // No app bar, so the header keeps its own contents below the status bar.
    final safeTop = MediaQuery.paddingOf(context).top;
    return Container(
      padding: EdgeInsets.fromLTRB(
        Dimens.screenPadding,
        safeTop + Dimens.lg,
        Dimens.screenPadding,
        Dimens.section,
      ),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer,
        borderRadius: const BorderRadius.vertical(
          bottom: Radius.circular(Dimens.radiusBlock),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  dateFormatWeekday(viewModel.today),
                  style: theme.textTheme.labelMedium,
                ),
                Text(
                  dateFormatDay(viewModel.today),
                  style: theme.textTheme.headlineMedium,
                ),
              ],
            ),
          ),
          ListenableBuilder(
            listenable: viewModel,
            builder: (context, _) => MemberAvatarStack(
              members: viewModel.membersOnToday,
              size: AvatarSize.large,
            ),
          ),
        ],
      ),
    );
  }
}
