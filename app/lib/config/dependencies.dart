import 'package:app/data/repositories/auth/auth_repository.dart';
import 'package:app/data/repositories/auth/auth_repository_supabase.dart';
import 'package:app/data/repositories/events/events_repository.dart';
import 'package:app/data/repositories/events/events_repository_supabase.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

List<SingleChildWidget> get providers {
  return [
    Provider(create: (context) => Supabase.instance.client),
    ChangeNotifierProvider(
      create: (context) =>
          AuthRepositorySupabase(context.read()) as AuthRepository,
    ),
    Provider(
      create: (context) =>
          EventsRepositorySupabase(context.read()) as EventsRepository,
    ),
  ];
}
