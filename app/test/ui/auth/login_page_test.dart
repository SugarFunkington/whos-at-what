import 'package:app/data/repositories/auth/auth_repository.dart';
import 'package:app/ui/auth/login_page.dart';
import 'package:app/ui/calendar/home_page.dart';
import 'package:app/utils/result.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../testing/fakes/repositories/fake_auth_repository.dart';
import '../../../testing/fakes/repositories/fake_events_repository.dart';

void main() {
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
    await tester.pumpWidget(
      MaterialApp(
        home: LoginPage(
          authRepository: FakeAuthRepository(),
          eventsRepository: FakeEventsRepository(),
        ),
      ),
    );

    await logIn(tester);

    expect(find.byType(HomePage), findsOneWidget);
    expect(find.byType(LoginPage), findsNothing);
  });

  testWidgets('failed login stays on the login page', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: LoginPage(
          authRepository: FakeAuthRepository(
            loginResult: const Result.error(
              AuthFailure('Invalid login credentials'),
            ),
          ),
          eventsRepository: FakeEventsRepository(),
        ),
      ),
    );

    await logIn(tester);

    expect(find.byType(LoginPage), findsOneWidget);
    expect(find.byType(HomePage), findsNothing);
  });
}
