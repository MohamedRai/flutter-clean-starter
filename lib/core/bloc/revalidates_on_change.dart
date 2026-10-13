import 'package:flutter_clean_starter/core/bloc/async_cubit.dart';
import 'package:flutter_clean_starter/core/bloc/async_state.dart';
import 'package:flutter_clean_starter/core/error/failures.dart';
import 'package:flutter_clean_starter/core/utils/validator.dart';

/// Clears field errors live as the user fixes them.
///
/// For an [AsyncCubit] whose use case is a `UseCaseWithValidation`: call
/// [revalidate] from a field's `onChanged`. It only acts while the cubit
/// shows a local [ValidationFailures]; server and network failures are left
/// untouched.
mixin RevalidatesOnChange<T, Params, TField> on AsyncCubit<T, Params> {
  /// The same validator the use case runs (`useCase.validator`).
  Validator<Params, TField> get validator;

  /// Re-validates [params] and updates (or clears) the displayed errors.
  void revalidate(Params params) {
    final current = state;
    if (current is! AsyncFailure<T> ||
        current.failure is! ValidationFailures<TField>) {
      return;
    }
    final failures = validator.validate(params);
    emit(failures == null ? AsyncInitial<T>() : AsyncFailure<T>(failures));
  }
}
