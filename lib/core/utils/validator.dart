import 'package:flutter_clean_starter/core/error/failures.dart';

/// Validates a [TParams] object and reports every invalid field at once.
///
/// [TField] identifies a field — usually a form-specific enum.
abstract interface class Validator<TParams, TField> {
  /// Returns the invalid fields, or `null` when [params] is valid.
  ValidationFailures<TField>? validate(TParams params);
}
