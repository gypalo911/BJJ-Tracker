# Project Styleguide Notes

Use this note as the repo-specific baseline before creating or extending shared style accessors.

## Current structure

- Shared styling code already exists in `bjjtracker/DesignSystem/`.
- `DesignSystem.swift` exposes shared spacer and color objects, while the shared font entry point is currently commented out.
- `DesignSystem+Color.swift` contains a few UIKit-based colors, but most of the app still uses asset colors directly through raw `Color("...")` calls.
- `DesignSystem+Font.swift` is mostly scaffolding. Font usage in the app is still mostly direct SwiftUI modifiers and a few `Font.custom("Rubik", size: 14)` calls.
- `bjjtracker/Helpers/Extensions/Color/Color.swift` is effectively empty and can be used for SwiftUI color accessors if that keeps the change local.

## Asset catalogs

Colors in `bjjtracker/Colors.xcassets/Colors/`:

- `Blue`
- `Competition`
- `DarkBlue`
- `DarkTabBar`
- `Gray`
- `GrayTextColor`
- `Green`
- `LightBlue`
- `LightBlue1`
- `LightGray`
- `LightLightGray`
- `LinearBG1`
- `LinearBG2`
- `LogoColor`
- `Purple`
- `PurpleBG`
- `RedPink`
- `Seminar`
- `Yellow`
- `darkenGreen`
- `darkenRed`
- `generalBG`
- `lightGreen`
- `lightRed`
- `listBG`
- `whiteBG`

Icons in `bjjtracker/Icons.xcassets/`:

- `activities`
- `addIcon`
- `archive`
- `arrowDown`
- `arrowUp`
- `back`
- `beltIcon`
- `calendar`
- `calendar2`
- `checkmark`
- `chevronRight`
- `close`
- `count`
- `createButton`
- `dashboard`
- `dashboard2`
- `done`
- `dotsAroundBelt`
- `edit`
- `eye`
- `filledCalendar`
- `info`
- `issue`
- `kimono`
- `language`
- `link`
- `location`
- `lock`
- `notification`
- `plus`
- `profile`
- `profile2`
- `rate`
- `search`
- `share`
- `star`
- `stats`
- `stats2`
- `triangle`
- `watch`

Images in `bjjtracker/Images.xcassets/`:

- `Logo`
- `LogoWithText`
- `apple-health`
- `apple-health-2x`
- `bjj`
- `buymeacoffee`
- `default-avatar`
- `patreon`
- `selectImage`

## Existing raw-usage hotspots

- Raw asset color usage is widespread across `Views/` and some model types such as `Activity.swift` and `Promotion.swift`.
- Raw image and icon usage is common in screen views, especially profile, sessions, dashboard, and techniques flows.
- SF Symbols are used alongside asset icons. Keep those represented separately in the style guide.
- Font usage is inconsistent: semantic SwiftUI fonts, `.system(...)`, and `Font.custom("Rubik", size: 14)` all exist today.
- Use project-wide search to inventory these literals before replacing them.

## Recommended migration shape

- Colors: expose semantic `Color` accessors and, when needed, matching `UIColor` accessors for UIKit consumers.
- Icons and images: use separate namespaces so consuming code makes the source explicit, for example an icon API for `Icons.xcassets` and an image API for `Images.xcassets`.
- Fonts: expose only repeated typography styles. Leave one-off local tweaks inline unless the user asks for a full typography system.
- Replacements: migrate feature-by-feature and verify rendering after each batch. Asset access refactors are easy to compile yet still visually regress.
