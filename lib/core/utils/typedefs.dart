import 'package:flutter_clean_starter/core/domain/result.dart';

/// The return type of every repository method and use case.
typedef FutureResult<T> = Future<Result<T>>;

/// A [FutureResult] that carries no value on success.
typedef FutureResultVoid = FutureResult<void>;

/// A [FutureResult] of a list.
typedef FutureResultList<T> = FutureResult<List<T>>;

/// A decoded JSON object.
typedef Json = Map<String, dynamic>;
