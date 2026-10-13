import 'package:equatable/equatable.dart';

/// The user's theme preference. A domain enum, so the domain layer does not
/// depend on Flutter's `ThemeMode`.
enum AppThemeMode {
  /// Follow the operating system.
  system,

  /// Always light.
  light,

  /// Always dark.
  dark,
}

/// User-adjustable app preferences.
final class AppSettings extends Equatable {
  /// Creates settings; defaults follow the system.
  const AppSettings({this.themeMode = AppThemeMode.system, this.languageCode});

  /// The preferred theme.
  final AppThemeMode themeMode;

  /// The preferred language (e.g. `fr`), or `null` to follow the device.
  final String? languageCode;

  /// Returns a copy with [themeMode] replaced.
  AppSettings withThemeMode(AppThemeMode themeMode) =>
      AppSettings(themeMode: themeMode, languageCode: languageCode);

  /// Returns a copy with [languageCode] replaced (`null` = device language).
  AppSettings withLanguageCode(String? languageCode) =>
      AppSettings(themeMode: themeMode, languageCode: languageCode);

  @override
  List<Object?> get props => [themeMode, languageCode];
}
