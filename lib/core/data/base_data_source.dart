import 'package:flutter_clean_starter/core/error/exception_mapper.dart';
import 'package:flutter_clean_starter/core/error/exceptions.dart';
import 'package:flutter_clean_starter/core/network/network_info.dart';
import 'package:flutter_clean_starter/core/utils/app_logger.dart';

/// Base class for data sources: guarantees that only [AppException]s ever
/// escape, via [safeCall].
abstract class BaseDataSource {
  /// Creates the data source.
  ///
  /// When [networkInfo] is given, [safeCall] fails fast with a
  /// [NetworkException] while the device is offline.
  const BaseDataSource({required this.exceptionMapper, this.networkInfo});

  /// Converts arbitrary errors into [AppException]s.
  final ExceptionMapper exceptionMapper;

  /// Optional connectivity check performed before each call.
  final NetworkInfo? networkInfo;

  /// Runs [call], converting anything it throws into an [AppException].
  Future<T> safeCall<T>(Future<T> Function() call) async {
    final networkInfo = this.networkInfo;
    if (networkInfo != null && !await networkInfo.isConnected) {
      throw const NetworkException(message: 'No network connection');
    }

    try {
      return await call();
    } on Object catch (error, stackTrace) {
      final mapped = exceptionMapper.map(error, stackTrace);
      // A 404 is often an expected outcome (e.g. "no match"), not a bug.
      if (mapped is NotFoundException) {
        AppLogger.warning('$runtimeType: $mapped');
      } else {
        AppLogger.error(
          '$runtimeType call failed',
          error: error,
          stackTrace: stackTrace,
        );
      }
      throw mapped;
    }
  }
}
