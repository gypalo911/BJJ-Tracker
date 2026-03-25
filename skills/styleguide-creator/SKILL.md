---
name: styleguide-creator
description: Create or update centralized style-guide accessors for fonts, colors, icons, and images in this BJJ Tracker codebase. Use when introducing design tokens, replacing raw style literals, auditing asset usage, or migrating views to shared design-system APIs.
---

# Styleguide Creator

Keep style-guide work aligned with the project’s current structure instead of introducing a new theming architecture.

## Project conventions

- Extend the existing `DesignSystem` before creating a new styling framework.
- Treat `bjjtracker/DesignSystem/` as the primary home for shared style tokens.
- Use `DesignSystem.shared.colors`, `DesignSystem.shared.fonts`, and `DesignSystem.shared.spacing` as the canonical entry points for shared styling.
- Use `DesignSystem.Color` and `DesignSystem.Typography` for semantic helper namespaces that power view modifiers such as `foregroundStyle(text:)` and `font(buttons:)`.
- Keep tokens grouped semantically inside those namespaces, while preserving short compatibility aliases only when existing code still depends on them.
- Treat `bjjtracker/Helpers/Extensions/Color/Color.swift` as a fallback location for lightweight SwiftUI helpers only when the work does not justify a `DesignSystem` change.
- Asset catalogs live at:
  - `bjjtracker/Colors.xcassets`
  - `bjjtracker/Icons.xcassets`
  - `bjjtracker/Images.xcassets`
- Centralize access through semantic APIs instead of repeating raw literals such as `Color("Blue")`, `Image("language")`, `UIImage(named: "default-avatar")`, or `Font.custom("Rubik", size: 14)` at call sites.
- Prefer semantic accessor names over raw asset names in consuming code. Keep the raw asset name mapping inside the style-guide layer.
- If the task is only to improve access and replace usages, do not rename asset-catalog entries unless the user explicitly asks for that migration.
- For colors, prefer semantic SwiftUI `Color` accessors backed by asset colors. Add UIKit accessors only where UIKit APIs require them.
- For images and icons, keep asset-backed accessors separate from SF Symbols. Do not mix `Image("...")` assets and `Image(systemName: "...")` symbols behind unclear names.
- For fonts, define reusable SwiftUI `Font` and matching `UIFont` helpers only for styles that repeat. Prefer token objects with both SwiftUI and UIKit representations over raw `Font.custom(...)` or `UIFont.systemFont(...)` at call sites.
- For spacing, keep a shared foundational scale in `DesignSystem.shared.spacing` and add semantic aliases for heavily reused layout patterns such as screen insets, chip padding, and section spacing.

## Workflow

1. Audit current raw style literals before editing anything.
2. Inspect the relevant feature code and choose the smallest shared API that removes duplication.
3. Add or update centralized accessors in `DesignSystem` under the appropriate `colors`, `fonts`, or `spacing` namespace.
4. Replace raw literals feature-by-feature instead of doing a blind project-wide swap.
5. Re-check the affected features and confirm the intended literals were reduced or eliminated.
6. Build the project after non-trivial replacements to catch typo-level regressions in asset names or helper signatures.

## Repo-specific checks

- Read [references/project-styleguide.md](references/project-styleguide.md) before larger migrations or when the current asset layout is unclear.
- Audit raw usages with project search before broad replacements. Search for:
  - `Color("`
  - `UIColor(named:`
  - `Image("`
  - `UIImage(named:`
  - `systemName:`
  - `Font.custom(`
  - `.font(.system`
  - `UIFont.systemFont`
- Before replacing many literals, search the owning feature to see whether a semantic accessor already exists under another name.
- When replacing assets, preserve rendering mode, sizing, and tint behavior. Centralizing lookup should not silently change view behavior.

## Output expectations

- Prefer minimal edits over a full design-system rewrite.
- Keep style-guide APIs semantic and easy to grep.
- Preserve existing asset names unless the task explicitly includes renaming catalogs.
- Flag inconsistent or duplicate style names instead of silently merging unrelated tokens.
