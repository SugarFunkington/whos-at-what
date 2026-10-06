import 'package:app/data/repositories/auth/auth_repository.dart';
import 'package:app/ui/auth/login/view_models/login_viewmodel.dart';
import 'package:app/utils/result.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../../testing/fakes/repositories/fake_auth_repository.dart';

void main() {
  test('login completes when the repository logs in', () async {
    final authRepository = FakeAuthRepository();
    final viewModel = LoginViewModel(authRepository: authRepository);

    await viewModel.login.execute(('parent@example.com', 'right'));

    expect(viewModel.login.completed, isTrue);
    expect(authRepository.isAuthenticated, isTrue);
  });

  test('login errors when the repository fails', () async {
    final viewModel = LoginViewModel(
      authRepository: FakeAuthRepository(
        loginResult: const Result.error(
          AuthFailure('Invalid login credentials'),
        ),
      ),
    );

    await viewModel.login.execute(('parent@example.com', 'wrong'));

    expect(viewModel.login.error, isTrue);
    expect(viewModel.login.completed, isFalse);
  });
}
