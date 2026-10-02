import 'package:app/data/repositories/events_repository.dart';
import 'package:app/domain/models/event.dart';
import 'package:app/ui/core/spacing.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key, required this.eventsRepository});

  final EventsRepository eventsRepository;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late final Future<List<Event>> _events;

  @override
  void initState() {
    super.initState();
    _events = widget.eventsRepository.fetchToday();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Today')),
      body: FutureBuilder<List<Event>>(
        future: _events,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Padding(
              padding: pagePadding,
              child: Text('Error: ${snapshot.error}'),
            );
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final events = snapshot.data!;
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
    );
  }
}
