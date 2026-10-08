import 'package:app/config/dependencies.dart';
import 'package:app/data/repositories/auth/auth_repository.dart';
import 'package:app/routing/router.dart';
import 'package:app/ui/core/themes/theme.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  LicenseRegistry.addLicense(_fontLicenses);

  await Supabase.initialize(
    url: const String.fromEnvironment('SUPABASE_URL'),
    publishableKey: const String.fromEnvironment('SUPABASE_PUBLISHABLE_KEY'),
  );

  runApp(MultiProvider(providers: providers, child: const MainApp()));
}

/// Bundled fonts aren't packages, so their licences must be added by hand to
/// show on Flutter's licence page.
Stream<LicenseEntry> _fontLicenses() async* {
  final manrope = await rootBundle.loadString('assets/fonts/manrope/OFL.txt');
  yield LicenseEntryWithLineBreaks(['Manrope'], manrope);
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      theme: AppTheme.lightTheme,
      routerConfig: router(context.read<AuthRepository>()),
    );
  }
}
