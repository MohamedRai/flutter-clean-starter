import 'package:flutter/foundation.dart';
import 'package:flutter_clean_starter/core/error/failures.dart';

/// One required field of a form, for [validateRequiredFields].
@immutable
class RequiredField<TField> {
  /// Describes a required field.
  const RequiredField(this.field, this.value, {required this.message});

  /// Identifies the field (a backend key or a form enum value).
  final TField field;

  /// The field's current value. Empty means `null`, a blank `String`, an
  /// empty `Iterable`, or `false` (an unticked checkbox).
  final Object? value;

  /// The (already localized) message shown when the field is empty.
  final String message;

  /// Whether [value] counts as empty.
  bool get isEmpty => switch (value) {
    null => true,
    final String text => text.trim().isEmpty,
    final Iterable<Object?> items => items.isEmpty,
    final bool flag => !flag,
    _ => false,
  };
}

/// Checks all [fields] in one pass and returns a [ValidationFailures]
/// naming every empty one, or `null` when nothing is missing.
///
/// Failures keep the order of [fields]: list them in on-screen order so the
/// form can scroll to the first one.
ValidationFailures<TField>? validateRequiredFields<TField>(
  List<RequiredField<TField>> fields,
) {
  final failures = <ValidationFailure<TField>>[
    for (final field in fields)
      if (field.isEmpty) ValidationFailure(field.message, field: field.field),
  ];
  return failures.isEmpty ? null : ValidationFailures(failures);
}
