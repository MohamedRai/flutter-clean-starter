import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_clean_starter/core/extensions/context_x.dart';
import 'package:flutter_clean_starter/core/l10n/gen/app_localizations.dart';
import 'package:flutter_clean_starter/core/theme/tokens/app_spacing.dart';
import 'package:flutter_clean_starter/features/settings/domain/entities/app_settings.dart';
import 'package:flutter_clean_starter/features/settings/presentation/cubit/settings_cubit.dart';

/// Theme and language preferences.
///
/// Reads the app-wide [SettingsCubit]. [onAccountTap] opens the protected
/// account page (demonstrates the router's auth guard).
class SettingsPage extends StatelessWidget {
  /// Creates the page.
  const SettingsPage({required this.onAccountTap, super.key});

  /// Opens the account page.
  final VoidCallback onAccountTap;

  /// Native names, so a user can always find their own language.
  static const _languageNames = {
    'en': 'English',
    'fr': 'Français',
    'ar': 'العربية',
  };

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final settings = context.watch<SettingsCubit>().state;
    final cubit = context.read<SettingsCubit>();

    return Scaffold(
      appBar: AppBar(title: Text(l10n.navSettings)),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
        children: [
          _SectionTitle(l10n.settingsTheme),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            child: SegmentedButton<AppThemeMode>(
              segments: [
                ButtonSegment(
                  value: AppThemeMode.system,
                  label: Text(l10n.themeSystem),
                  icon: const Icon(Icons.brightness_auto),
                ),
                ButtonSegment(
                  value: AppThemeMode.light,
                  label: Text(l10n.themeLight),
                  icon: const Icon(Icons.light_mode),
                ),
                ButtonSegment(
                  value: AppThemeMode.dark,
                  label: Text(l10n.themeDark),
                  icon: const Icon(Icons.dark_mode),
                ),
              ],
              selected: {settings.themeMode},
              onSelectionChanged: (s) => cubit.setThemeMode(s.single),
            ),
          ),
          _SectionTitle(l10n.settingsLanguage),
          RadioGroup<String?>(
            groupValue: settings.languageCode,
            onChanged: cubit.setLanguage,
            child: Column(
              children: [
                RadioListTile<String?>(
                  value: null,
                  title: Text(l10n.languageSystem),
                ),
                for (final locale in AppLocalizations.supportedLocales)
                  RadioListTile<String?>(
                    value: locale.languageCode,
                    title: Text(
                      _languageNames[locale.languageCode] ??
                          locale.languageCode,
                    ),
                  ),
              ],
            ),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.person_outline),
            title: Text(l10n.settingsAccount),
            trailing: const Icon(Icons.chevron_right),
            onTap: onAccountTap,
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.lg,
        AppSpacing.lg,
        AppSpacing.sm,
      ),
      child: Text(
        text,
        style: context.textTheme.titleSmall?.copyWith(
          color: context.colors.primary,
        ),
      ),
    );
  }
}
