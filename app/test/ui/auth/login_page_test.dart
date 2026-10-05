import 'package:app/data/repositories/auth/auth_repository.dart';
import 'package:app/data/repositories/events/events_repository.dart';
import 'package:app/ui/auth/login_page.dart';
import 'package:app/ui/calendar/home_page.dart';
import 'package:app/utils/result.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import '../../../testing/fakes/repositories/fake_auth_repository.dart';
import '../../../testing/fakes/repositories/fake_events_repository.dart';

void main() {
  Widget app(AuthRepository authRepository) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthRepository>.value(value: authRepository),
        Provider<EventsRepository>.value(value: FakeEventsRepository()),
      ],
      child: const MaterialApp(home: LoginPage()),
    );
  }

  Future<void> logIn(WidgetTester tester) async {
    await tester.enterText(
      find.widgetWithText(TextField, 'Email'),
      'parent@example.com',
    );
    await tester.enterText(
      find.widgetWithText(TextField, 'Password'),
      'password123',
    );
    await tester.tap(find.widgetWithText(FilledButton, 'Log in'));
    await tester.pumpAndSettle();
  }

  testWidgets('successful login navigates to home', (tester) async {
    await tester.pumpWidget(app(FakeAuthRepository()));

    await logIn(tester);

    expect(find.byType(HomePage), findsOneWidget);
    expect(find.byType(LoginPage), findsNothing);
  });

  testWidgets('failed login stays on the login page', (tester) async {
    await tester.pumpWidget(
      app(
        FakeAuthRepository(
          loginResult: const Result.error(
            AuthFailure('Invalid login credentials'),
          ),
        ),
      ),
    );

    await logIn(tester);

    expect(find.byType(LoginPage), findsOneWidget);
    expect(find.byType(HomePage), findsNothing);
  });
}
