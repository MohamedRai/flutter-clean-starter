import 'package:intl/intl.dart';

/// Convenience operations on [DateTime].
extension DateTimeX on DateTime {
  /// `YYYY-MM-DD`, the format most APIs expect for plain dates.
  String toIsoDate() =>
      '${year.toString().padLeft(4, '0')}-'
      '${month.toString().padLeft(2, '0')}-'
      '${day.toString().padLeft(2, '0')}';

  /// Whether this and [other] fall on the same calendar day.
  bool isSameDay(DateTime other) =>
      year == other.year && month == other.month && day == other.day;

  /// This date at midnight.
  DateTime get dateOnly => DateTime(year, month, day);

  /// Localized medium date, e.g. `Oct 13, 2026` / `13 oct. 2026`.
  String formatMedium([String? locale]) =>
      DateFormat.yMMMd(locale).format(this);
}
