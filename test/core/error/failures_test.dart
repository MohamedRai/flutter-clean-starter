import 'package:flutter_clean_starter/core/error/exceptions.dart';
import 'package:flutter_clean_starter/core/error/failures.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Failure.fromException', () {
    test('maps every exception to its failure', () {
      const retry = Duration(seconds: 3);
      final cases = <AppException, Failure>{
        const ServerException(statusCode: 500): const ServerFailure(
          statusCode: 500,
        ),
        const NetworkException(): const NetworkFailure(),
        const CacheException(): const CacheFailure(),
        const ValidationException(field: 'email', message: 'bad'):
            const ValidationFailure<String>('bad', field: 'email'),
        const UnauthorizedException(): const UnauthorizedFailure(),
        const ForbiddenException(): const ForbiddenFailure(),
        const NotFoundException(): const NotFoundFailure(),
        const BadRequestException(): const BadRequestFailure(),
        const RateLimitException(retryAfter: retry): const RateLimitFailure(
          retryAfter: retry,
        ),
        const UnknownException(): const UnknownFailure(),
      };
      for (final MapEntry(key: exception, value: failure) in cases.entries) {
        expect(Failure.fromException(exception), failure, reason: '$exception');
      }
    });

    test('a validation exception without a field gets an empty field', () {
      expect(
        Failure.fromException(const ValidationException()),
        const ValidationFailure<String>('', field: ''),
      );
    });
  });

  test('isRetryable is true only for transient failures', () {
    expect(const NetworkFailure().isRetryable, isTrue);
    expect(const ServerFailure().isRetryable, isTrue);
    expect(const RateLimitFailure().isRetryable, isTrue);
    expect(const NotFoundFailure().isRetryable, isFalse);
    expect(const UnauthorizedFailure().isRetryable, isFalse);
  });

  group('errorFor', () {
    const failures = ValidationFailures<String>([
      ValidationFailure('Required', field: 'name'),
    ]);

    test('reads a field from ValidationFailures', () {
      expect(failures.errorFor('name'), 'Required');
      expect(failures.errorFor('email'), isNull);
    });

    test('reads a field from a single ValidationFailure', () {
      const single = ValidationFailure<String>('Bad', field: 'email');
      expect(single.errorFor('email'), 'Bad');
      expect(single.errorFor('name'), isNull);
    });

    test('is null for non-validation failures', () {
      expect(const NetworkFailure().errorFor('name'), isNull);
    });
  });

  test('AppException.toString includes message and cause', () {
    expect(const NetworkException().toString(), 'NetworkException');
    expect(
      const ServerException(message: 'boom', cause: 'x').toString(),
      'ServerException(boom — x)',
    );
  });
}
