import 'package:app/data/repositories/auth/auth_repository.dart';
import 'package:app/data/repositories/events/events_repository.dart';
import 'package:app/routing/router.dart';
import 'package:app/ui/auth/login/widgets/login_screen.dart';
import 'package:app/ui/home/widgets/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import '../../testing/fakes/repositories/fake_auth_repository.dart';
import '../../testing/fakes/repositories/fake_events_repository.dart';

void main() {
  Widget app(AuthRepository authRepository) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthRepository>.value(value: authRepository),
        Provider<EventsRepository>.value(value: FakeEventsRepository()),
      ],
      child: MaterialApp.router(routerConfig: router(authRepository)),
    );
  }

  testWidgets('logged out starts on the login screen', (tester) async {
    await tester.pumpWidget(app(FakeAuthRepository()));
    await tester.pumpAndSettle();

    expect(find.byType(LoginScreen), findsOneWidget);
  });

  testWidgets('logging in moves to the home screen', (tester) async {
    final authRepository = FakeAuthRepository();
    await tester.pumpWidget(app(authRepository));
    await tester.pumpAndSettle();

    await authRepository.login(email: 'parent@example.com', password: 'x');
    await tester.pumpAndSettle();

    expect(find.byType(HomeScreen), findsOne);
    expect(find.byType(LoginScreen), findsNothing);
  });
}
