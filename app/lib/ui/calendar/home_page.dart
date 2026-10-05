import 'package:app/data/repositories/events/events_repository.dart';
import 'package:app/domain/models/event.dart';
import 'package:app/ui/core/spacing.dart';
import 'package:app/utils/result.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late final Future<Result<List<Event>>> _events;

  @override
  void initState() {
    super.initState();
    _events = context.read<EventsRepository>().fetchTodaysEvents();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Today')),
      body: FutureBuilder<Result<List<Event>>>(
        future: _events,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Padding(
              padding: pagePadding,
              child: Text('Unexpected error: ${snapshot.error}'),
            );
          }

          final result = snapshot.data;
          if (result == null) {
            return const Center(child: CircularProgressIndicator());
          }

          switch (result) {
            case Error():
              return Padding(
                padding: pagePadding,
                child: Text('Error: ${result.error}'),
              );
            case Ok():
              final events = result.value;
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
          }
        },
      ),
    );
  }
}
