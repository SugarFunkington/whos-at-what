import 'package:app/data/repositories/auth/auth_repository.dart';
import 'package:app/utils/command.dart';
import 'package:app/utils/result.dart';
import 'package:flutter/foundation.dart';

class LoginViewModel {
  LoginViewModel({required this._authRepository}) {
    login = CommandWithArg(_login);
  }

  final AuthRepository _authRepository;
  late final CommandWithArg<void, (String email, String password)> login;

  Future<Result<void>> _login((String, String) credentials) async {
    final (email, password) = credentials;
    final result = await _authRepository.login(
      email: email.trim(),
      password: password,
    );

    if (result is Error) {
      debugPrint('Login failed: ${result.error}');
    }

    return result;
  }
}
