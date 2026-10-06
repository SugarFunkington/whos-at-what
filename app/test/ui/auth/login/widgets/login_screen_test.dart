import 'package:app/data/repositories/auth/auth_repository.dart';
import 'package:app/data/repositories/events/events_repository.dart';
import 'package:app/ui/auth/login/view_models/login_viewmodel.dart';
import 'package:app/ui/auth/login/widgets/login_screen.dart';
import 'package:app/ui/home/widgets/home_screen.dart';
import 'package:app/utils/result.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import '../../../../../testing/fakes/repositories/fake_auth_repository.dart';
import '../../../../../testing/fakes/repositories/fake_events_repository.dart';

void main() {
  Widget app(AuthRepository authRepository) {
    return Provider<EventsRepository>.value(
      value: FakeEventsRepository(),
      child: MaterialApp(
        home: LoginScreen(
          viewModel: LoginViewModel(authRepository: authRepository),
        ),
      ),
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
    expect(find.byType(HomeScreen), findsOneWidget);
    expect(find.byType(LoginScreen), findsNothing);
  });

  testWidgets('failed login stays on the login screen', (tester) async {
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
    expect(find.byType(LoginScreen), findsOneWidget);
    expect(find.byType(HomeScreen), findsNothing);
  });
}
