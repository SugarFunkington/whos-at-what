import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:app/data/repositories/auth_repository.dart';
import 'package:app/data/repositories/events_repository.dart';
import 'package:app/ui/calendar/home_page.dart';
import 'package:app/ui/auth/login_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: const String.fromEnvironment('SUPABASE_URL'),
    publishableKey: const String.fromEnvironment('SUPABASE_PUBLISHABLE_KEY'),
  );

  final client = Supabase.instance.client;
  final authRepository = AuthRepository(client);
  final eventsRepository = EventsRepository(client);

  runApp(
    MaterialApp(
      home: authRepository.isLoggedIn
          ? HomePage(eventsRepository: eventsRepository)
          : LoginPage(
              authRepository: authRepository,
              eventsRepository: eventsRepository,
            ),
    ),
  );
}
