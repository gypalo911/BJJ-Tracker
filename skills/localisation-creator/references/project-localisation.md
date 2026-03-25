# Project localisation conventions

## Scope

This repo currently localises user-facing strings with classic iOS `.lproj` folders and `Localizable.strings` files:

- `bjjtracker/en.lproj/Localizable.strings`
- `bjjtracker/uk.lproj/Localizable.strings`
- `bjjtracker/es.lproj/Localizable.strings`
- `bjjtracker/fr.lproj/Localizable.strings`
- `bjjtracker/pt-BR.lproj/Localizable.strings`

## Code patterns in use

- Nested localisation enums
  Prefer a per-entity namespace such as:

  ```swift
  extension SomeViewModel {
      enum Localisation {
          static var title: String { "Title".localizedString }
          static func calories(_ value: String) -> String {
              "%@ calories burned".localized(with: [value])
          }
      }
  }
  ```

  Existing precedent in this repo: `bjjtracker/Views/Screens/Sessions/NewSessionViewViewModel.swift`.

- `String.localizedString`
  Use for static keys:

  ```swift
  "Dashboard".localizedString
  ```

- `String.localized(with:)`
  Use for formatted strings with `%@` arguments:

  ```swift
  "%@ calories burned".localized(with: ["\(totalEnergyBurned)"])
  ```

Implementation lives in `bjjtracker/Helpers/Extensions/String+extension.swift`.

## Important conventions

- The English phrase in code is the localisation key.
- `en.lproj/Localizable.strings` is currently close to empty, so the app often falls back to the key itself for English.
- Every entity that owns user-facing copy should keep its localisation keys in a nested `Localisation` enum or another tight namespace instead of free-floating literals.
- Views should consume those namespaced keys where practical, for example via `typealias Localisation = FeatureViewModel.Localisation`.
- Existing translations use `%@` placeholders. Keep the same placeholder shape across locales.
- Some strings intentionally include markdown or line breaks. Preserve them exactly.

## Things to watch for

- Do not introduce `\(value)` interpolation into the key itself.
- Do not add new inline string literals to views or view models when the string belongs in that entity’s localisation enum.
- Do not convert this repo to `.xcstrings` unless explicitly asked.
- Do not rename keys casually. Since the key is the English source text, renaming a visible English phrase can invalidate existing translations.
- Check for existing placeholder bugs before copying a pattern forward. Example: a key containing `\(techniques.count)` is suspicious because it bypasses the `%@` placeholder convention.

## Suggested edit process

1. Find the Swift call site using `rg`.
2. Find or create the owning type’s `Localisation` enum.
3. Determine whether the string is static or formatted.
4. Update every locale file.
5. Run the audit script to verify key coverage and placeholders.
6. If the task changed UI copy in code, verify the new key exists in all target locale files.
