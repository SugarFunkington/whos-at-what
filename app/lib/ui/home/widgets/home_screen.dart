import 'package:app/ui/core/themes/dimens.dart';
import 'package:app/ui/home/view_models/home_viewmodel.dart';
import 'package:app/ui/home/widgets/home_header.dart';
import 'package:app/ui/home/widgets/time_slot.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key, required this.viewModel});

  final HomeViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Always built, so the header shows while loading and on error too.
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            HomeHeader(viewModel: viewModel),
            ListenableBuilder(
              listenable: viewModel.load,
              builder: (context, child) {
                if (viewModel.load.running) {
                  return const Padding(
                    padding: EdgeInsets.only(top: Dimens.section),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }
                if (viewModel.load.error) {
                  return Padding(
                    padding: Dimens.edgeInsetsScreen,
                    child: Column(
                      children: [
                        const Text("Couldn't load today's events."),
                        const SizedBox(height: 12),
                        FilledButton(
                          onPressed: viewModel.load.execute,
                          child: const Text('Try again'),
                        ),
                      ],
                    ),
                  );
                }
                return child!;
              },
              child: ListenableBuilder(
                listenable: viewModel,
                builder: (context, _) {
                  final slots = viewModel.timeSlots;
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _ScheduleHeading(count: viewModel.events.length),
                      for (final (index, slot) in slots.indexed)
                        Padding(
                          key: ValueKey(slot.first.id),
                          padding: const EdgeInsets.symmetric(
                            horizontal: Dimens.screenPadding,
                          ),
                          child: TimeSlot(
                            events: slot,
                            membersFor: viewModel.membersFor,
                            isFirst: index == 0,
                            isLast: index == slots.length - 1,
                          ),
                        ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// "Today's schedule", with how many events there are on the right.
class _ScheduleHeading extends StatelessWidget {
  const _ScheduleHeading({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        Dimens.screenPadding,
        Dimens.section,
        Dimens.screenPadding,
        Dimens.md,
      ),
      child: Row(
        children: [
          Expanded(
            child: Text("Today's schedule", style: textTheme.titleLarge),
          ),
          // Display only, like the notes chip; keeps the count's own style.
          Chip(
            label: Text(count == 1 ? '$count event' : '$count events'),
            labelStyle: textTheme.bodyMedium,
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
        ],
      ),
    );
  }
}
