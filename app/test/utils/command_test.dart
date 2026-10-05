import 'dart:async';

import 'package:app/utils/command.dart';
import 'package:app/utils/result.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('completed is true after a successful action', () async {
    final command = Command<int>(() async => const Result.ok(42));

    await command.execute();

    expect(command.completed, isTrue);
    expect(command.result, isA<Ok<int>>());
  });

  test('error is true after a failed action', () async {
    final command = Command<int>(() async => Result.error(Exception('boom')));

    await command.execute();

    expect(command.error, isTrue);
    expect(command.completed, isFalse);
  });

  test('running is true only while the action runs', () async {
    final command = Command<void>(() async => const Result.ok(null));

    final future = command.execute();
    expect(command.running, isTrue);

    await future;
    expect(command.running, isFalse);
  });

  test('ignores execute while already running', () async {
    var calls = 0;
    final command = Command<void>(() async {
      calls++;
      return const Result.ok(null);
    });

    final first = command.execute();
    unawaited(command.execute());
    await first;

    expect(calls, 1);
  });

  test('CommandWithArg passes its argument to the action', () async {
    final command = CommandWithArg<int, int>((n) async => Result.ok(n * 2));

    await command.execute(21);

    final result = command.result;
    expect(result, isA<Ok<int>>());
    expect((result as Ok<int>).value, 42);
  });
}
