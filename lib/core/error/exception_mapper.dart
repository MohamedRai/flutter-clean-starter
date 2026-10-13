import 'package:flutter_clean_starter/core/error/exceptions.dart';

/// Converts any thrown object into a typed [AppException].
///
/// Data sources use one so that only [AppException]s ever leave the data
/// layer. See `HttpExceptionMapper` for the HTTP implementation.
abstract interface class ExceptionMapper {
  /// Maps [error] (thrown with [stackTrace]) to an [AppException].
  AppException map(Object error, [StackTrace? stackTrace]);
}
