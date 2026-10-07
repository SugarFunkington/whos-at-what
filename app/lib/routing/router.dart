import 'package:app/data/repositories/auth/auth_repository.dart';
import 'package:app/routing/routes.dart';
import 'package:app/ui/auth/login/view_models/login_viewmodel.dart';
import 'package:app/ui/auth/login/widgets/login_screen.dart';
import 'package:app/ui/home/view_models/home_viewmodel.dart';
import 'package:app/ui/home/widgets/home_screen.dart';
import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

GoRouter router(AuthRepository authRepository) => GoRouter(
  initialLocation: Routes.home,
  refreshListenable: authRepository,
  redirect: _redirect,
  routes: [
    GoRoute(
      path: Routes.login,
      builder: (context, state) => LoginScreen(
        viewModel: LoginViewModel(authRepository: context.read()),
      ),
    ),
    GoRoute(
      path: Routes.home,
      builder: (context, state) => HomeScreen(
        viewModel: HomeViewModel(
          eventsRepository: context.read(),
          membersRepository: context.read(),
        ),
      ),
    ),
  ],
);

String? _redirect(BuildContext context, GoRouterState state) {
  final loggedIn = context.read<AuthRepository>().isAuthenticated;
  final loggingIn = state.matchedLocation == Routes.login;

  if (!loggedIn) return Routes.login;
  if (loggingIn) return Routes.home;

  return null;
}
