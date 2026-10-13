import 'package:flutter_clean_starter/core/domain/result.dart';
import 'package:flutter_clean_starter/core/error/failures.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const failure = NetworkFailure();
  const success = Result<int>.success(2);
  const error = Result<int>.failure(failure);

  group('Result', () {
    test('success exposes its value', () {
      expect(success.isSuccess, isTrue);
      expect(success.isFailure, isFalse);
      expect(success.getOrNull(), 2);
      expect(success.failureOrNull(), isNull);
      expect(success.getOrElse((_) => 0), 2);
    });

    test('failure exposes its failure', () {
      expect(error.isFailure, isTrue);
      expect(error.getOrNull(), isNull);
      expect(error.failureOrNull(), failure);
      expect(error.getOrElse((_) => 0), 0);
    });

    test('when runs exactly one branch', () {
      expect(success.when(success: (v) => 'v$v', failure: (_) => 'f'), 'v2');
      expect(error.when(success: (v) => 'v$v', failure: (_) => 'f'), 'f');
    });

    test('map transforms success and passes failures through', () {
      expect(success.map((v) => v * 10), const Result<int>.success(20));
      expect(error.map((v) => v * 10), const Result<int>.failure(failure));
    });

    test('flatMap chains and short-circuits', () async {
      Future<Result<String>> next(int v) async => Result.success('$v!');
      expect(await success.flatMap(next), const Result.success('2!'));
      expect(await error.flatMap(next), const Result<String>.failure(failure));
    });

    test('onSuccess / onFailure run side effects and chain', () {
      final seen = <String>[];
      success.onSuccess((v) => seen.add('s$v')).onFailure((_) => seen.add('f'));
      error.onSuccess((v) => seen.add('s$v')).onFailure((_) => seen.add('f'));
      expect(seen, ['s2', 'f']);
    });

    test('has value equality and readable toString', () {
      expect(success, const SuccessResult(2));
      expect(success.hashCode, const SuccessResult(2).hashCode);
      expect(error, const FailureResult<int>(failure));
      expect(error.hashCode, const FailureResult<int>(failure).hashCode);
      expect(success.toString(), 'Result.success(2)');
      expect(error.toString(), contains('Result.failure'));
    });
  });
}
