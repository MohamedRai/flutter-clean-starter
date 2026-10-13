# Localization

Flutter's built-in `gen-l10n` with ARB files. Supported: **English**
(template), **French**, **Arabic** (right-to-left).

| Path | Content |
|---|---|
| `l10n.yaml` | Generator config |
| `lib/core/l10n/arb/app_<locale>.arb` | Translations |
| `lib/core/l10n/gen/` | Generated `AppLocalizations` (committed) |

The files live in `core/` (not `app/`) so that core widgets (`ErrorView`,
`EmptyState`) and the failure-to-message mapping can be localized without
`core` depending on `app`.

## Using strings

```dart
Text(context.l10n.postsTitle)
Text(context.l10n.postAuthor(post.userId))      // placeholder
failure.localizedMessage(context.l10n)          // Failure → text
```

`context.l10n` comes from `ContextX` in `core/extensions/context_x.dart`.

## Adding a string

1. Add the key + `@key` description to `app_en.arb`:

   ```json
   "orderCount": "{count, plural, =0{No orders} =1{1 order} other{{count} orders}}",
   "@orderCount": {
     "description": "Number of orders in the list.",
     "placeholders": { "count": { "type": "int" } }
   }
   ```

2. Add the translation to `app_fr.arb` and `app_ar.arb` (same key).
3. `flutter gen-l10n` (or `make gen`).

Rules: keys are lowerCamelCase prefixed by area (`postsTitle`,
`failureNetwork`); never concatenate translated fragments; use ICU plurals
and selects. The `add-localization` Claude skill automates this.

## Choosing the locale

`MaterialApp.locale` comes from `SettingsCubit` (`null` = follow the
device). Users switch language in **Settings**; the choice is persisted in
`KeyValueStorage`.

## RTL (Arabic)

Flutter mirrors layouts automatically when the locale is Arabic. To keep
that working:

- Use `EdgeInsetsDirectional`, `AlignmentDirectional`,
  `PositionedDirectional`, and `start`/`end` instead of `left`/`right`.
- Directional Material icons (`Icons.arrow_back`, `Icons.chevron_right`, …)
  are declared with `matchTextDirection` and flip automatically; custom
  directional icons need `Transform.flip` when `context.isRtl`.
- Test it: `posts_page_test.dart` pumps the page in Arabic and asserts
  `TextDirection.rtl`; the integration test switches to Arabic in Settings.

## Adding a language

Copy `app_en.arb` to `app_<code>.arb`, set `"@@locale": "<code>"`,
translate every value, run `flutter gen-l10n`. The new locale appears
automatically in `AppLocalizations.supportedLocales` and in the Settings
language list (add its native name to `SettingsPage._languageNames`).
