import 'package:flutter/widgets.dart';

import 'package:flutter_clean_starter/core/error/failures.dart';

/// Gives a form's [State] a [GlobalKey] per backend field key, and a way to
/// scroll the nearest [Scrollable] to the first field a [Failure] names —
/// so a validation error that arrived off-screen (e.g. the user scrolled
/// down before submitting) is brought into view instead of only showing up
/// as an easy-to-miss inline `errorText`.
///
/// ```dart
/// class _MyStepState extends State<MyStep> with FieldErrorScrollMixin {
///   @override
///   Widget build(BuildContext context) {
///     return TextField(
///       key: fieldKey('email'),
///       errorText: failure?.errorFor('email'),
///       ...
///     );
///   }
/// }
/// ```
///
/// Call [scrollToFirstError] from wherever the failure is observed (e.g. a
/// `BlocConsumer`/`BlocListener`'s `listener`), passing the fields in the
/// same top-to-bottom order they appear on screen.
mixin FieldErrorScrollMixin<T extends StatefulWidget> on State<T> {
  final Map<String, GlobalKey> _fieldKeys = {};

  static const _bannerField = '_FieldErrorScrollMixin.banner';

  /// The [GlobalKey] to attach to the field rendering backend field [field]
  /// (e.g. `'email'`, `'first_name'`) — reused across rebuilds so it stays
  /// attached to the same field instance.
  GlobalKey fieldKey(String field) =>
      _fieldKeys.putIfAbsent(field, GlobalKey.new);

  /// The [GlobalKey] for this screen's generic failure banner — the
  /// fallback text shown when a [Failure] doesn't name a field rendered
  /// here (a network/server error, or a validation error for a field from
  /// a different step of a shared-cubit flow). Attach it via
  /// `key: bannerKey` on that banner widget so [scrollToFirstError] can
  /// still bring the error into view when it's off-screen below the
  /// fields — without this, a banner appended after a long field list is
  /// easy to miss entirely.
  GlobalKey get bannerKey => fieldKey(_bannerField);

  /// Points backend field key [alias] at the same [GlobalKey] as
  /// [canonical] — for a backend field that isn't its own UI element but
  /// is bundled into another field's widget (e.g. a `country_code` shown
  /// inside a combined phone-number field).
  /// A failure naming [alias] then scrolls to, and counts as "visible
  /// inline" at, [canonical]'s field. Safe to call in any order relative
  /// to [canonical]'s own [fieldKey] call — creates it if needed.
  void aliasFieldKey(String alias, String canonical) {
    _fieldKeys[alias] = fieldKey(canonical);
  }

  /// Whether [failure] has a validation message for a field that's
  /// actually rendered on *this* screen (i.e. has a registered
  /// [fieldKey]) — use this to decide whether a generic banner is still
  /// needed, or whether the error is already visible inline. A multi-step
  /// flow sharing one cubit can carry a failure naming a field from a
  /// different step; that case still needs the banner, since there's
  /// nothing on this screen showing it.
  bool hasVisibleFieldError(Failure? failure, List<String> fields) {
    if (failure == null) return false;
    return fields.any(
      (field) =>
          _fieldKeys.containsKey(field) && failure.errorFor(field) != null,
    );
  }

  /// Scrolls to the first field in [fieldsInOrder] that both [failure] has
  /// a validation message for *and* is actually rendered on this screen
  /// (has a registered [fieldKey]) — a shared cubit's failure can name a
  /// field that lives on a different step of a multi-step flow, in which
  /// case there's nothing here to scroll to and a
  /// generic banner should carry the message instead.
  ///
  /// Falls back to [bannerKey] (if this screen registered one) when no
  /// field matched — otherwise a failure with no per-field breakdown (a
  /// network/server error) or one naming a field from another step would
  /// scroll nowhere, leaving the generic banner wherever it happens to
  /// land in the layout, easy to miss below a long field list.
  void scrollToFirstError(Failure? failure, List<String> fieldsInOrder) {
    if (failure == null) return;

    for (final field in fieldsInOrder) {
      if (failure.errorFor(field) == null) continue;

      final key = _fieldKeys[field];
      if (key == null) continue;

      _scrollTo(key);
      return;
    }

    final banner = _fieldKeys[_bannerField];
    if (banner != null) _scrollTo(banner);
  }

  void _scrollTo(GlobalKey key) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final fieldContext = key.currentContext;
      if (fieldContext == null) return;
      Scrollable.ensureVisible(
        fieldContext,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        alignment: 0.1,
      );
    });
  }
}
