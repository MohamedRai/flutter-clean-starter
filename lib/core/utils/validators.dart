/// Reusable, pure input checks.
///
/// Each returns `true` when the input is valid. They return booleans (not
/// messages) so that callers decide on wording and localization — either in
/// a `Validator` (domain) or in a `TextFormField.validator` (presentation).
abstract final class Validators {
  static final RegExp _email = RegExp(
    r'^[\w.!#$%&*+/=?^`{|}~-]+@[A-Za-z0-9](?:[A-Za-z0-9-]{0,61}[A-Za-z0-9])?'
    r'(?:\.[A-Za-z0-9](?:[A-Za-z0-9-]{0,61}[A-Za-z0-9])?)+$',
  );

  static final RegExp _phone = RegExp(r'^\+?[0-9 ()-]{6,20}$');

  /// Whether [value] is non-null and not only whitespace.
  static bool isNotBlank(String? value) =>
      value != null && value.trim().isNotEmpty;

  /// Whether [value] looks like an e-mail address.
  static bool isEmail(String? value) =>
      value != null && _email.hasMatch(value.trim());

  /// Whether [value] looks like a phone number (digits, spaces, `()+-`).
  static bool isPhone(String? value) =>
      value != null && _phone.hasMatch(value.trim());

  /// Whether [value] is an absolute `http`/`https` URL.
  static bool isHttpUrl(String? value) {
    final uri = Uri.tryParse(value?.trim() ?? '');
    return uri != null &&
        uri.hasAuthority &&
        (uri.scheme == 'http' || uri.scheme == 'https');
  }

  /// Whether [value] has at least [min] characters (after trimming).
  static bool hasMinLength(String? value, int min) =>
      (value?.trim().length ?? 0) >= min;

  /// Whether [value] has at most [max] characters (after trimming).
  static bool hasMaxLength(String? value, int max) =>
      (value?.trim().length ?? 0) <= max;
}
