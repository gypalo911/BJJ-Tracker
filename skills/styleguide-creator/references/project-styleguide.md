# Project Styleguide Notes

Use this note as the repo-specific baseline before creating or extending shared style accessors.

## Current structure

- Shared styling code lives in `bjjtracker/DesignSystem/`.
- `DesignSystem.swift` is the canonical entry point and exposes `DesignSystem.shared.colors`, `DesignSystem.shared.fonts`, and `DesignSystem.shared.spacing`.
- `DesignSystem+Color.swift` owns the semantic mapping from color assets such as `Blue`, `generalBG`, or `lightGreen` into grouped project tokens.
- `DesignSystem+Font.swift` owns shared typography tokens and should expose both SwiftUI and UIKit representations when a style is reused.
- `DesignSystem+Spacer.swift` owns the core spacing scale and semantic aliases for recurring layout values.
- `DesignSystem.Color` and `DesignSystem.Typography` are the semantic namespaces used by view helper modifiers in `DesignSystem/Extensions/`.
- Raw `Color("...")`, `Font.custom(...)`, and repeated spacing literals should be treated as migration candidates when touching a feature.
