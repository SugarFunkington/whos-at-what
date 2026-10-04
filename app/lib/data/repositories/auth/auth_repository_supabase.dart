import "dart:async";

import "package:app/data/repositories/auth/auth_repository.dart";
import "package:app/utils/result.dart";
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthRepositorySupabase extends AuthRepository {
  AuthRepositorySupabase(this._client) {
    _authChanges = _client.auth.onAuthStateChange.listen((_) {
      notifyListeners();
    });
  }

  final SupabaseClient _client;
  late final StreamSubscription<AuthState> _authChanges;

  @override
  bool get isAuthenticated => _client.auth.currentSession != null;

  @override
  Future<Result<void>> login({
    required String email,
    required String password,
  }) async {
    try {
      await _client.auth.signInWithPassword(email: email, password: password);
      return const Result.ok(null);
    } on AuthException catch (error) {
      return Result.error(AuthFailure(error.message));
    } on Exception catch (error) {
      return Result.error(error);
    }
  }

  @override
  dispose() {
    _authChanges.cancel();
    super.dispose();
  }
}
