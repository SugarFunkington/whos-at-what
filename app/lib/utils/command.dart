import 'package:app/utils/result.dart';
import 'package:flutter/foundation.dart';

typedef CommandAction<T> = Future<Result<T>> Function();
typedef CommandActionWithArg<T, A> = Future<Result<T>> Function(A);

abstract class _Command<T> extends ChangeNotifier {
  bool _running = false;
  bool get running => _running;

  Result<T>? _result;
  Result<T>? get result => _result;

  bool get completed => _result is Ok;
  bool get error => _result is Error;

  void clearResult() {
    _result = null;
    notifyListeners();
  }

  Future<void> _execute(CommandAction<T> action) async {
    if (_running) return;

    _running = true;
    _result = null;
    notifyListeners();

    try {
      _result = await action();
    } finally {
      _running = false;
      notifyListeners();
    }
  }
}

class Command<T> extends _Command<T> {
  Command(this._action);

  final CommandAction<T> _action;

  Future<void> execute() => _execute(_action);
}

/// For several values, make [A] a record, e.g. `CommandWithArg<void, (String, String)>`.
class CommandWithArg<T, A> extends _Command<T> {
  CommandWithArg(this._action);

  final CommandActionWithArg<T, A> _action;

  Future<void> execute(A argument) => _execute(() => _action(argument));
}
