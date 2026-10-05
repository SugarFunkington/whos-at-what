import 'package:app/config/dependencies.dart';
import 'package:app/data/repositories/auth/auth_repository.dart';
import 'package:app/ui/auth/login_page.dart';
import 'package:app/ui/calendar/home_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: const String.fromEnvironment('SUPABASE_URL'),
    publishableKey: const String.fromEnvironment('SUPABASE_PUBLISHABLE_KEY'),
  );

  runApp(MultiProvider(providers: providers, child: const MainApp()));
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    final isAuthenticated = context.read<AuthRepository>().isAuthenticated;

    return MaterialApp(
      home: isAuthenticated ? const HomePage() : const LoginPage(),
    );
  }
}
