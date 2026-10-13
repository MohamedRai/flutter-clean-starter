/// Convenience operations on [String].
extension StringX on String {
  /// Whether the string is empty or only whitespace.
  bool get isBlank => trim().isEmpty;

  /// The string with its first character upper-cased.
  String get capitalized =>
      isEmpty ? this : '${this[0].toUpperCase()}${substring(1)}';

  /// The string cut to [maxLength] characters, ending with [ellipsis] when
  /// it was shortened.
  String truncate(int maxLength, {String ellipsis = '…'}) =>
      length <= maxLength ? this : '${substring(0, maxLength)}$ellipsis';
}

/// Convenience operations on nullable [String].
extension NullableStringX on String? {
  /// Whether the string is `null`, empty, or only whitespace.
  bool get isNullOrBlank => this?.trim().isEmpty ?? true;

  /// `null` when the string is blank, the trimmed string otherwise.
  String? get nullIfBlank {
    final trimmed = this?.trim();
    return (trimmed == null || trimmed.isEmpty) ? null : trimmed;
  }
}
