import 'package:app/data/repositories/auth/auth_repository.dart';
import 'package:app/ui/auth/login/view_models/login_viewmodel.dart';
import 'package:app/ui/auth/login/widgets/login_screen.dart';
import 'package:app/utils/result.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../../testing/fakes/repositories/fake_auth_repository.dart';

void main() {
  Widget app(AuthRepository authRepository) {
    return MaterialApp(
      home: LoginScreen(
        viewModel: LoginViewModel(authRepository: authRepository),
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

  testWidgets('tapping Log in logs in', (tester) async {
    final authRepository = FakeAuthRepository();
    await tester.pumpWidget(app(authRepository));

    await logIn(tester);

    expect(authRepository.isAuthenticated, isTrue);
  });

  testWidgets('failed login stays on the login screen', (tester) async {
    final authRepository = FakeAuthRepository(
      loginResult: const Result.error(AuthFailure('Invalid login credentials')),
    );
    await tester.pumpWidget(app(authRepository));

    await logIn(tester);

    expect(authRepository.isAuthenticated, isFalse);
    expect(find.byType(LoginScreen), findsOneWidget);
  });
}
