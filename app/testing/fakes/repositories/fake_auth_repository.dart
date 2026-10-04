import 'package:app/data/repositories/auth/auth_repository.dart';
import 'package:app/utils/result.dart';

class FakeAuthRepository extends AuthRepository {
  FakeAuthRepository({this.loginResult = const Result.ok(null)});

  final Result<void> loginResult;

  bool _isAuthenticated = false;

  @override
  bool get isAuthenticated => _isAuthenticated;

  @override
  Future<Result<void>> login({
    required String email,
    required String password,
  }) async {
    if (loginResult is Ok) {
      _isAuthenticated = true;
      notifyListeners();
    }
    return loginResult;
  }
}
