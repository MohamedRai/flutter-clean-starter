---
name: add-localization
description: Add, rename or translate user-facing strings in every ARB file (English, French, Arabic) and regenerate AppLocalizations. Use whenever new UI text is introduced, when the user asks for translations, or when adding a new language.
---

# Add localization

ARB files: `lib/core/l10n/arb/app_en.arb` (template), `app_fr.arb`,
`app_ar.arb`. Config: `l10n.yaml`. Generated code:
`lib/core/l10n/gen/` (committed, never hand-edited).

## 1. Add the key to the template

In `app_en.arb`, add the key (lowerCamelCase, prefixed by area:
`ordersTitle`, `orderDeleteConfirm`) and an `@key` entry with a
`description`. Placeholders need types:

```json
"orderCount": "{count, plural, =0{No orders} =1{1 order} other{{count} orders}}",
"@orderCount": {
  "description": "Number of orders in the list.",
  "placeholders": { "count": { "type": "int" } }
}
```

## 2. Translate in every other ARB

Add the same key to `app_fr.arb` and `app_ar.arb` with a real, natural
translation (no English fallbacks, no machine-literal phrasing). Arabic:
keep placeholders intact; text direction is handled by Flutter. Keep keys
in the same order across files.

## 3. Regenerate and use

```sh
flutter gen-l10n
```

Use it as `context.l10n.orderCount(n)`. Never concatenate translated
fragments; use placeholders instead.

## 4. New language

Copy `app_en.arb` to `app_<code>.arb`, set `"@@locale"`, translate every
value, run `flutter gen-l10n`. For RTL languages, check the main screens in
that locale (see the Arabic widget test in `posts_page_test.dart`).

## 5. Verify

`flutter analyze` (missing keys fail compilation) and `flutter test`.
