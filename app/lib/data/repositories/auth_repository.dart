import 'package:supabase_flutter/supabase_flutter.dart';

class AuthFailure implements Exception {
  const AuthFailure(this.message);

  final String message;

  @override
  String toString() => 'AuthFailure: $message';
}

class AuthRepository {
  AuthRepository(this._client);

  final SupabaseClient _client;

  bool get isLoggedIn => _client.auth.currentSession != null;

  Future<void> signIn({required String email, required String password}) async {
    try {
      await _client.auth.signInWithPassword(email: email, password: password);
    } on AuthException catch (error) {
      throw AuthFailure(error.message);
    }
  }
}
