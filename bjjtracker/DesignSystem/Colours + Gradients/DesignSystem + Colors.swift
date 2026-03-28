//
//  DesignSystem + Colors.swift
//  bjjtracker
//
//  Created by Petro Hupalo on 09.07.2023.
//

import SwiftUI
import UIKit

protocol DesignSystemColorRepresentable: Equatable {
    var color: SwiftUI.Color { get }
    var uiColor: UIColor { get }
}

extension DesignSystemColorRepresentable {
    var uiColor: UIColor {
        UIColor(color)
    }
}

extension DesignSystem.Color {
    enum Background: DesignSystemColorRepresentable {
        case background
        case secondary
        case tertiary
        case quaternary
        case calendarMonthHeader

        var color: SwiftUI.Color {
            switch self {
            case .background:
                return DesignSystem.shared.colors.background.primary
            case .secondary:
                return DesignSystem.shared.colors.surface.brand
            case .tertiary:
                return DesignSystem.shared.colors.surface.muted
            case .quaternary:
                return .black
            case .calendarMonthHeader:
                return DesignSystem.shared.colors.surface.brand
            }
        }
    }

    enum Text: DesignSystemColorRepresentable {
        case text
        case darkText
        case secondary
        case secondaryAlternative
        case tertiary
        case quaternary
        case onColor

        var color: SwiftUI.Color {
            switch self {
            case .text:
                return DesignSystem.shared.colors.text.primary
            case .darkText:
                return DesignSystem.shared.colors.darkText
            case .secondary, .secondaryAlternative:
                return DesignSystem.shared.colors.brand.primary
            case .tertiary:
                return DesignSystem.shared.colors.text.secondary
            case .quaternary:
                return DesignSystem.shared.colors.text.tertiary
            case .onColor:
                return DesignSystem.shared.colors.text.inverse
            }
        }
    }

    enum Icon: DesignSystemColorRepresentable {
        case brand
        case icon
        case secondary
        case secondaryAlternative
        case tertiary
        case tertiaryAlternative
        case quaternary
        case onColor

        var color: SwiftUI.Color {
            switch self {
            case .brand:
                return DesignSystem.shared.colors.brand.primary
            case .icon:
                return DesignSystem.shared.colors.brand.secondary
            case .secondary, .secondaryAlternative:
                return DesignSystem.shared.colors.brand.primary
            case .tertiary:
                return DesignSystem.shared.colors.text.secondary
            case .tertiaryAlternative, .quaternary:
                return DesignSystem.shared.colors.text.placeholder
            case .onColor:
                return DesignSystem.shared.colors.text.inverse
            }
        }
    }

    enum UI: DesignSystemColorRepresentable {
        case fill
        case fillAlternative
        case fillSecondary
        case fillTertiary
        case fillQuaternary
        case fillQuinary
        case border
        case borderAlternative
        case borderSecondary
        case borderTertiary
        case borderQuaternary
        case borderQuinary

        var color: SwiftUI.Color {
            switch self {
            case .fill, .fillAlternative, .border, .borderAlternative:
                return DesignSystem.shared.colors.brand.primary
            case .fillSecondary, .borderSecondary:
                return DesignSystem.shared.colors.surface.primary
            case .fillTertiary, .borderTertiary:
                return DesignSystem.shared.colors.text.placeholder
            case .fillQuaternary, .borderQuaternary:
                return DesignSystem.shared.colors.border.subtle
            case .fillQuinary:
                return DesignSystem.shared.colors.surface.muted
            case .borderQuinary:
                return DesignSystem.shared.colors.brand.secondary
            }
        }
    }

    enum Brand: DesignSystemColorRepresentable {
        case airtour

        var color: SwiftUI.Color {
            .black
        }
    }

    enum Border: DesignSystemColorRepresentable {
        case border
        case secondary
        case tertiary
        case quinary

        var color: SwiftUI.Color {
            switch self {
            case .border:
                return DesignSystem.shared.colors.border.subtle
            case .secondary:
                return DesignSystem.shared.colors.surface.primary
            case .tertiary:
                return DesignSystem.shared.colors.surface.brand
            case .quinary:
                return DesignSystem.shared.colors.brand.secondary
            }
        }
    }

    enum Disabled: DesignSystemColorRepresentable {
        case disabled
        case soft
        case strong

        var color: SwiftUI.Color {
            switch self {
            case .disabled:
                return DesignSystem.shared.colors.border.subtle
            case .soft:
                return DesignSystem.shared.colors.surface.muted
            case .strong:
                return DesignSystem.shared.colors.text.placeholder
            }
        }
    }

    enum Selected: DesignSystemColorRepresentable {
        case selected
        case secondary
        case tertiary
        case quaternary

        var color: SwiftUI.Color {
            switch self {
            case .selected:
                return DesignSystem.shared.colors.brand.primary
            case .secondary:
                return DesignSystem.shared.colors.brand.secondary
            case .tertiary:
                return DesignSystem.shared.colors.surface.brand
            case .quaternary:
                return DesignSystem.shared.colors.background.primary
            }
        }
    }

    enum Pressed: DesignSystemColorRepresentable {
        case pressed
        case pressedAlternative
        case secondary
        case tertiary

        var color: SwiftUI.Color {
            switch self {
            case .pressed, .pressedAlternative:
                return DesignSystem.shared.colors.accent.primary
            case .secondary:
                return DesignSystem.shared.colors.surface.muted
            case .tertiary:
                return DesignSystem.shared.colors.text.placeholder
            }
        }
    }

    enum Overlay: DesignSystemColorRepresentable {
        case dark
        case light
        case lightStrong
        case accentBorderGradientStop0
        case accentBorderGradientStop100
        case systemGradientStop

        var color: SwiftUI.Color {
            switch self {
            case .dark:
                return .black.opacity(0.4)
            case .light:
                return .white.opacity(0.4)
            case .lightStrong:
                return .white.opacity(0.85)
            case .accentBorderGradientStop0:
                return DesignSystem.shared.colors.share.gradientStart
            case .accentBorderGradientStop100:
                return DesignSystem.shared.colors.share.gradientEnd
            case .systemGradientStop:
                return .black
            }
        }
    }

    enum Skeleton: DesignSystemColorRepresentable {
        case skeleton
        case secondary

        var color: SwiftUI.Color {
            switch self {
            case .skeleton:
                return DesignSystem.shared.colors.surface.muted
            case .secondary:
                return DesignSystem.shared.colors.border.subtle
            }
        }
    }

    enum Status: DesignSystemColorRepresentable {
        case errorStrong
        case errorSoft
        case deepGreenAccessible
        case successStrong
        case successSoft
        case infoStrong
        case infoSoft
        case warning

        var color: SwiftUI.Color {
            switch self {
            case .errorStrong:
                return DesignSystem.shared.colors.status.errorStrong
            case .errorSoft:
                return DesignSystem.shared.colors.status.errorSoft
            case .deepGreenAccessible, .successStrong:
                return DesignSystem.shared.colors.status.successStrong
            case .successSoft:
                return DesignSystem.shared.colors.status.successSoft
            case .infoStrong:
                return DesignSystem.shared.colors.brand.primary
            case .infoSoft:
                return DesignSystem.shared.colors.surface.brand
            case .warning:
                return DesignSystem.shared.colors.highlight.primary
            }
        }
    }

    enum Promotional: DesignSystemColorRepresentable {
        case deals
        case secondary
        case tertiary
        case quaternary
        case quinary
        case senary

        var color: SwiftUI.Color {
            switch self {
            case .deals:
                return DesignSystem.shared.colors.accent.destructive
            case .secondary:
                return DesignSystem.shared.colors.highlight.primary
            case .tertiary:
                return .black
            case .quaternary:
                return DesignSystem.shared.colors.status.success
            case .quinary:
                return DesignSystem.shared.colors.surface.brand
            case .senary:
                return DesignSystem.shared.colors.border.subtle
            }
        }
    }

    enum Shadow: DesignSystemColorRepresentable {
        case shadowLevel1
        case shadowLevel2

        var color: SwiftUI.Color {
            switch self {
            case .shadowLevel1:
                return .black.opacity(0.15)
            case .shadowLevel2:
                return .black.opacity(0.08)
            }
        }
    }

    enum Specific: DesignSystemColorRepresentable {
        case new
        case favourite
        case counter
        case rating
        case tuiRating
        case unselectedRating
        case graphics
        case graphicsSecondary
        case graphicsTertiary
        case graphicsQuaternary
        case graphicsQuinary
        case graphicsSenary
        case graphicsSepternary
        case paymentButton

        var color: SwiftUI.Color {
            switch self {
            case .new, .favourite:
                return DesignSystem.shared.colors.accent.destructive
            case .counter:
                return DesignSystem.shared.colors.brand.primary
            case .rating, .tuiRating:
                return DesignSystem.shared.colors.highlight.primary
            case .unselectedRating, .graphics:
                return DesignSystem.shared.colors.border.subtle
            case .graphicsSecondary, .graphicsQuinary:
                return DesignSystem.shared.colors.brand.secondary
            case .graphicsTertiary:
                return DesignSystem.shared.colors.surface.muted
            case .graphicsQuaternary, .graphicsSenary, .graphicsSepternary:
                return DesignSystem.shared.colors.surface.brand
            case .paymentButton:
                return .black
            }
        }
    }
}
