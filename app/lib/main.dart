import 'package:app/config/dependencies.dart';
import 'package:app/data/repositories/auth/auth_repository.dart';
import 'package:app/routing/router.dart';
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
    return MaterialApp.router(
      routerConfig: router(context.read<AuthRepository>()),
    );
  }
}
