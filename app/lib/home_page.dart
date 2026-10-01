import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'events_repository.dart';
import 'styles/spacing.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late final Future<List<Event>> _events;

  @override
  void initState() {
    super.initState();
    _events = EventsRepository(Supabase.instance.client).fetchToday();
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
