import 'package:flutter/material.dart';
import 'package:flutter_clean_starter/core/theme/tokens/app_spacing.dart';

/// Styling for [KeyValueTable]. Every color/text style defaults to the
/// current theme.
@immutable
class KeyValueTableStyle {
  /// Creates a style.
  const KeyValueTableStyle({
    this.keyStyle,
    this.valueStyle,
    this.rowPadding = const EdgeInsets.symmetric(vertical: AppSpacing.md),
    this.showDividers = true,
    this.dividerColor,
    this.keyFlex = 1,
    this.valueFlex = 1,
  });

  /// Text style of the key column.
  final TextStyle? keyStyle;

  /// Text style of the value column.
  final TextStyle? valueStyle;

  /// Padding of each row.
  final EdgeInsets rowPadding;

  /// Whether rows are separated by dividers.
  final bool showDividers;

  /// Divider color; defaults to `ColorScheme.outlineVariant`.
  final Color? dividerColor;

  /// Relative width of the key column.
  final int keyFlex;

  /// Relative width of the value column.
  final int valueFlex;
}

/// One row of a [KeyValueTable].
///
/// Subclass it to add new kinds of rows without touching the table
/// (open/closed principle).
abstract class KeyValueEntry {
  /// Creates a row labelled [keyLabel].
  const KeyValueEntry({required this.keyLabel});

  /// The (already localized) label shown in the left column.
  final String keyLabel;

  /// Builds the left column. Override to add e.g. a leading icon.
  Widget buildKey(BuildContext context, TextStyle? style) => Text(
    keyLabel,
    style:
        style ??
        Theme.of(context).textTheme.bodyMedium
            ?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
  );

  /// Builds the right column.
  Widget buildValue(BuildContext context, TextStyle? style);
}

/// A row whose value is plain text.
class TextEntry extends KeyValueEntry {
  /// Creates the row.
  const TextEntry({required super.keyLabel, required this.value});

  /// The (already localized) value.
  final String value;

  @override
  Widget buildValue(BuildContext context, TextStyle? style) =>
      Text(value, style: style ?? Theme.of(context).textTheme.bodyMedium);
}

/// A row whose value is any widget (chip, badge, switch, ...).
class WidgetEntry extends KeyValueEntry {
  /// Creates the row.
  const WidgetEntry({required super.keyLabel, required this.value});

  /// The value widget.
  final Widget value;

  @override
  Widget buildValue(BuildContext context, TextStyle? style) => value;
}

/// A two-column key/value table, e.g. for detail pages.
///
/// ```dart
/// KeyValueTable(
///   entries: [
///     TextEntry(keyLabel: l10n.name, value: user.name),
///     WidgetEntry(keyLabel: l10n.status, value: StatusChip(user.status)),
///   ],
/// )
/// ```
class KeyValueTable extends StatelessWidget {
  /// Creates the table.
  const KeyValueTable({
    required this.entries,
    this.style = const KeyValueTableStyle(),
    super.key,
  });

  /// The rows, top to bottom.
  final List<KeyValueEntry> entries;

  /// Styling.
  final KeyValueTableStyle style;

  @override
  Widget build(BuildContext context) {
    final divider = Divider(
      height: 1,
      color: style.dividerColor ?? Theme.of(context).colorScheme.outlineVariant,
    );
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (final (index, entry) in entries.indexed) ...[
          if (index > 0 && style.showDividers) divider,
          Padding(
            padding: style.rowPadding,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: style.keyFlex,
                  child: entry.buildKey(context, style.keyStyle),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  flex: style.valueFlex,
                  child: entry.buildValue(context, style.valueStyle),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}
