import 'package:app/config/dependencies.dart';
import 'package:app/data/repositories/auth/auth_repository.dart';
import 'package:app/data/repositories/events/events_repository.dart';
import 'package:app/ui/auth/login/view_models/login_viewmodel.dart';
import 'package:app/ui/auth/login/widgets/login_screen.dart';
import 'package:app/ui/home/view_models/home_viewmodel.dart';
import 'package:app/ui/home/widgets/home_screen.dart';
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
      home: isAuthenticated
          ? HomeScreen(
              viewModel: HomeViewModel(
                eventsRepository: context.read<EventsRepository>(),
              ),
            )
          : LoginScreen(
              viewModel: LoginViewModel(
                authRepository: context.read<AuthRepository>(),
              ),
            ),
    );
  }
}
