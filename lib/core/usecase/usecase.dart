import 'package:equatable/equatable.dart';
import 'package:flutter_clean_starter/core/domain/result.dart';
import 'package:flutter_clean_starter/core/utils/typedefs.dart';
import 'package:flutter_clean_starter/core/utils/validator.dart';

/// A single application action — one class, one verb (`GetPosts`,
/// `SignIn`, ...).
///
/// Use cases are the only entry point from presentation into the domain:
/// blocs and cubits call use cases, never repositories.
///
/// ```dart
/// final class GetPostById implements UseCase<Post, GetPostByIdParams> {
///   const GetPostById(this._repository);
///   final PostRepository _repository;
///
///   @override
///   FutureResult<Post> call(GetPostByIdParams params) =>
///       _repository.getPostById(params.id);
/// }
/// ```
abstract interface class UseCase<T, Params> {
  /// Runs the use case.
  FutureResult<T> call(Params params);
}

/// A use case that emits a stream of values (e.g. watching a cache).
abstract interface class StreamUseCase<T, Params> {
  /// Starts watching.
  Stream<T> call(Params params);
}

/// The parameter type for use cases that take no input.
///
/// ```dart
/// final posts = await getPosts(const NoParams());
/// ```
final class NoParams extends Equatable {
  /// Creates the (only) value.
  const NoParams();

  @override
  List<Object?> get props => const [];
}

/// A [UseCase] that validates its [Params] locally before doing any work.
///
/// When [validator] reports problems, [call] returns them as a
/// `ValidationFailures` without calling [execute] — so no network request
/// is made for input that is obviously wrong.
abstract class UseCaseWithValidation<T, Params, TField>
    implements UseCase<T, Params> {
  /// Creates the use case with its [validator].
  const UseCaseWithValidation(this.validator);

  /// Checks [Params] before [execute] runs.
  final Validator<Params, TField> validator;

  @override
  FutureResult<T> call(Params params) async {
    final failure = validator.validate(params);
    if (failure != null) return FailureResult<T>(failure);
    return await execute(params);
  }

  /// The use case logic. Override this instead of [call].
  FutureResult<T> execute(Params params);
}
