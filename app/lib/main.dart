import 'package:app/data/repositories/auth/auth_repository_supabase.dart';
import 'package:app/data/repositories/events/events_repository_supabase.dart';
import 'package:app/ui/auth/login_page.dart';
import 'package:app/ui/calendar/home_page.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: const String.fromEnvironment('SUPABASE_URL'),
    publishableKey: const String.fromEnvironment('SUPABASE_PUBLISHABLE_KEY'),
  );

  final client = Supabase.instance.client;
  final authRepository = AuthRepositorySupabase(client);
  final eventsRepository = EventsRepositorySupabase(client);

  runApp(
    MaterialApp(
      home: authRepository.isAuthenticated
          ? HomePage(eventsRepository: eventsRepository)
          : LoginPage(
              authRepository: authRepository,
              eventsRepository: eventsRepository,
            ),
    ),
  );
}
