import 'package:app/utils/result.dart';
import 'package:flutter/foundation.dart';

class AuthFailure implements Exception {
  const AuthFailure(this.message);

  final String message;

  @override
  String toString() => 'AuthFailure: $message';
}

abstract class AuthRepository extends ChangeNotifier {
  bool get isAuthenticated;

  Future<Result<void>> login({required String email, required String password});
}
