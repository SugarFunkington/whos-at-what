import 'package:app/ui/core/date_format_day.dart';
import 'package:app/ui/core/spacing.dart';
import 'package:app/ui/home/view_models/home_viewmodel.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key, required this.viewModel});

  final HomeViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(dateFormatDay(viewModel.today))),
      body: ListenableBuilder(
        listenable: viewModel.load,
        builder: (context, child) {
          if (viewModel.load.running) {
            return const Center(child: CircularProgressIndicator());
          }
          if (viewModel.load.error) {
            return Padding(
              padding: pagePadding,
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
            final events = viewModel.events;
            return ListView.builder(
              itemCount: events.length,
              itemBuilder: (context, index) {
                final event = events[index];
                return ListTile(
                  key: ValueKey(event.id),
                  title: Text(event.title),
                  subtitle: Text(
                    TimeOfDay.fromDateTime(event.startsAt).format(context),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
