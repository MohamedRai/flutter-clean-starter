import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_clean_starter/core/error/exceptions.dart';
import 'package:flutter_clean_starter/core/network/http_exception_mapper.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const mapper = HttpExceptionMapper();
  final request = RequestOptions(path: '/x');

  DioException badResponse(
    int status, {
    Object? data,
    Map<String, List<String>> headers = const {},
  }) => DioException(
    requestOptions: request,
    type: DioExceptionType.badResponse,
    response: Response<Object?>(
      requestOptions: request,
      statusCode: status,
      data: data,
      headers: Headers.fromMap(headers),
    ),
  );

  test('maps status codes to exceptions', () {
    expect(mapper.map(badResponse(400)), isA<BadRequestException>());
    expect(mapper.map(badResponse(409)), isA<BadRequestException>());
    expect(mapper.map(badResponse(401)), isA<UnauthorizedException>());
    expect(mapper.map(badResponse(403)), isA<ForbiddenException>());
    expect(mapper.map(badResponse(404)), isA<NotFoundException>());
    expect(mapper.map(badResponse(422)), isA<ValidationException>());
    expect(mapper.map(badResponse(429)), isA<RateLimitException>());
    expect(
      mapper.map(badResponse(503)),
      isA<ServerException>().having((e) => e.statusCode, 'status', 503),
    );
    expect(mapper.map(badResponse(418)), isA<ServerException>());
  });

  test('maps connectivity problems to NetworkException', () {
    for (final type in [
      DioExceptionType.connectionTimeout,
      DioExceptionType.sendTimeout,
      DioExceptionType.receiveTimeout,
      DioExceptionType.connectionError,
      DioExceptionType.badCertificate,
    ]) {
      expect(
        mapper.map(DioException(requestOptions: request, type: type)),
        isA<NetworkException>(),
        reason: '$type',
      );
    }
    expect(mapper.map(const SocketException('down')), isA<NetworkException>());
    expect(mapper.map(TimeoutException('slow')), isA<NetworkException>());
    expect(
      mapper.map(
        DioException(
          requestOptions: request,
          error: const SocketException('x'),
        ),
      ),
      isA<NetworkException>(),
    );
  });

  test('passes AppExceptions through and unwraps mapped DioExceptions', () {
    const original = NotFoundException();
    expect(mapper.map(original), same(original));
    expect(
      mapper.map(DioException(requestOptions: request, error: original)),
      same(original),
    );
  });

  test('maps cancellations, parsing errors and the rest', () {
    expect(
      mapper.map(
        DioException(requestOptions: request, type: DioExceptionType.cancel),
      ),
      isA<UnknownException>(),
    );
    expect(mapper.map(const FormatException('bad')), isA<ServerException>());
    expect(mapper.map(StateError('?')), isA<UnknownException>());
    expect(
      mapper.map(DioException(requestOptions: request)),
      isA<UnknownException>(),
    );
  });

  test('extracts messages and fields from common error bodies', () {
    expect(mapper.extractMessage({'message': 'a'}), 'a');
    expect(mapper.extractMessage({'error': 'b'}), 'b');
    expect(
      mapper.extractMessage({
        'error': {'message': 'c'},
      }),
      'c',
    );
    expect(mapper.extractMessage('plain'), 'plain');
    expect(mapper.extractMessage(42), isNull);

    final validation = mapper.map(
      badResponse(422, data: {'field': 'email', 'message': 'taken'}),
    );
    expect(
      validation,
      isA<ValidationException>()
          .having((e) => e.field, 'field', 'email')
          .having((e) => e.message, 'message', 'taken'),
    );
  });

  group('parseRetryAfter', () {
    Headers headers(Map<String, List<String>> map) => Headers.fromMap(map);

    test('reads seconds', () {
      expect(
        mapper.parseRetryAfter(
          headers({
            'retry-after': ['30'],
          }),
        ),
        const Duration(seconds: 30),
      );
    });

    test('reads an HTTP date', () {
      final now = DateTime.utc(2026, 1, 1, 12);
      expect(
        mapper.parseRetryAfter(
          headers({
            'retry-after': [
              HttpDate.format(now.add(const Duration(minutes: 1))),
            ],
          }),
          now: now,
        ),
        const Duration(minutes: 1),
      );
    });

    test('falls back to RateLimit-Reset, else null', () {
      expect(
        mapper.parseRetryAfter(
          headers({
            'ratelimit-reset': ['5'],
          }),
        ),
        const Duration(seconds: 5),
      );
      expect(mapper.parseRetryAfter(headers({})), isNull);
    });
  });
}
