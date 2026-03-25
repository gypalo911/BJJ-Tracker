---
name: localisation-creator
description: Create or update app localisation assets for this BJJ Tracker codebase. Use when adding UI copy, translating new or existing strings, auditing locale coverage, or keeping `Localizable.strings` files aligned across `en`, `uk`, `es`, `fr`, and `pt-BR`.
---

# Localisation Creator

Update localisation work to match the project’s current iOS conventions instead of introducing a new i18n system.

## Project conventions

- Use `bjjtracker/<locale>.lproj/Localizable.strings` as the source of translated strings.
- Keep translated locale files aligned: `uk`, `es`, `fr`, `pt-BR`.
- Treat the English source text in Swift as the lookup key. The current app often relies on key fallback for English, so `en.lproj/Localizable.strings` may stay sparse.
- Define localisation keys close to the owning type. Each view model, feature enum, or similar entity should expose a nested `Localisation` enum or equivalent namespaced container for its keys.
- Prefer `Localisation.someKey` references in views and view models over scattering raw string literals through UI code.
- Use `String.localizedString` for plain keys and `String.localized(with:)` for formatted keys.
- Preserve formatting tokens exactly, especially `%@`, line breaks, punctuation, and markdown markers like `**bold**`.
- Do not introduce Swift interpolation inside localisation keys. If a string is dynamic, use placeholders like `%@` in the key and translations.

## Workflow

1. Inspect the relevant SwiftUI or service code to find the current key shape.
2. If the UI text is new, add it through the owning type’s `Localisation` enum instead of embedding a new raw string at the call site.
3. Add or update translations in every `Localizable.strings` file under `bjjtracker/*.lproj/`.
4. Keep translated entries grouped near the matching feature section when practical.
5. Run `scripts/audit_localizable_strings.py` from this skill folder to check non-English missing keys and placeholder mismatches.
6. If you changed formatted strings, re-read the touched entries and confirm every locale preserves the same placeholder count and order.

## Repo-specific checks

- Read [references/project-localisation.md](references/project-localisation.md) before larger localisation changes or when the key usage pattern is unclear.
- Use the audit script for every non-trivial change:

```bash
python3 skills/localisation-creator/scripts/audit_localizable_strings.py
```

- If the report shows placeholder mismatches, fix those before considering the task complete.
- Use `--strict-en` only when the task explicitly requires complete English entries in `en.lproj/Localizable.strings`.
- When touching a feature that still uses inline string literals, prefer extracting them into that feature’s local `Localisation` enum as part of the change.

## Output expectations

- Prefer minimal edits over broad reformatting of `.strings` files.
- Preserve existing comments and section headings.
- Flag suspicious existing keys rather than silently rewriting unrelated translations.
