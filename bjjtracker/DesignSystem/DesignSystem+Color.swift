//
//  DesignSystem+Color.swift
//  bjjtracker
//
//  Created by Petro Hupalo on 09.07.2023.
//

import SwiftUI
import UIKit

extension DesignSystem {
    public enum Color {}

    /// Shared project palette backed by the asset catalogue.
    public struct Colors {
        public let brand = Brand()
        public let accent = Accent()
        public let background = Background()
        public let text = Text()
        public let border = Border()
        public let surface = Surface()
        public let status = Status()
        public let activity = Activity()
        public let share = Share()
        public let highlight = Highlight()
        public let appleHealth = AppleHealth()

        /// UIKit-only dynamic color for activity indicators.
        public let activityIndicator = UIColor(hex: "#1D2028") | UIColor(hex: "#FFFFFF")

        public var blue: SwiftUI.Color { brand.primary }
        public var darkText: SwiftUI.Color { text.dark }
        public var darkBlue: SwiftUI.Color { brand.secondary }
        public var purple: SwiftUI.Color { accent.primary }
        public var purpleBackground: SwiftUI.Color { accent.surface }
        public var redPink: SwiftUI.Color { accent.destructive }
        public var green: SwiftUI.Color { status.success }
        public var competition: SwiftUI.Color { activity.competition }
        public var seminar: SwiftUI.Color { activity.seminar }
        public var gray: SwiftUI.Color { text.secondary }
        public var grayText: SwiftUI.Color { text.tertiary }
        public var lightGray: SwiftUI.Color { border.subtle }
        public var lightLightGray: SwiftUI.Color { surface.muted }
        public var lightBlue: SwiftUI.Color { surface.brand }
        public var lightBlueStrong: SwiftUI.Color { surface.brandStrong }
        public var lightGreen: SwiftUI.Color { status.successSoft }
        public var darkenGreen: SwiftUI.Color { status.successStrong }
        public var lightRed: SwiftUI.Color { status.errorSoft }
        public var darkenRed: SwiftUI.Color { status.errorStrong }
        public var generalBackground: SwiftUI.Color { background.primary }
        public var listBackground: SwiftUI.Color { background.list }
        public var logoColor: SwiftUI.Color { background.logo }
        public var linearBG1: SwiftUI.Color { share.gradientStart }
        public var linearBG2: SwiftUI.Color { share.gradientEnd }
        public var yellow: SwiftUI.Color { highlight.primary }

        public init() {}

        public struct Brand {
            public let primary = SwiftUI.Color("Blue")
            public let secondary = SwiftUI.Color("DarkBlue")

            public init() {}
        }

        public struct Accent {
            public let primary = SwiftUI.Color("Purple")
            public let surface = SwiftUI.Color("PurpleBG")
            public let destructive = SwiftUI.Color("RedPink")

            public init() {}
        }

        public struct Background {
            public let primary = SwiftUI.Color("generalBG")
            public let list = SwiftUI.Color("listBG")
            public let logo = SwiftUI.Color("LogoColor")

            public init() {}
        }

        public struct Text {
            public let primary = SwiftUI.Color("Blue")
            public let secondary = SwiftUI.Color("Gray")
            public let tertiary = SwiftUI.Color("GrayTextColor")
            public let inverse = SwiftUI.Color.white
            public let placeholder = SwiftUI.Color("LightGray")
            public let dark = SwiftUI.Color("Dark")

            public init() {}
        }

        public struct Border {
            public let primary = SwiftUI.Color("Blue")
            public let subtle = SwiftUI.Color("LightGray")

            public init() {}
        }

        public struct Surface {
            public let primary = SwiftUI.Color.white
            public let muted = SwiftUI.Color("LightLightGray")
            public let brand = SwiftUI.Color("LightBlue")
            public let brandStrong = SwiftUI.Color("LightBlue1")

            public init() {}
        }

        public struct Status {
            public let success = SwiftUI.Color("Green")
            public let successStrong = SwiftUI.Color("darkenGreen")
            public let successSoft = SwiftUI.Color("lightGreen")
            public let errorStrong = SwiftUI.Color("darkenRed")
            public let errorSoft = SwiftUI.Color("lightRed")

            public init() {}
        }

        public struct Activity {
            public let training = SwiftUI.Color("Green")
            public let competition = SwiftUI.Color("Competition")
            public let seminar = SwiftUI.Color("Seminar")

            public init() {}
        }

        public struct Share {
            public let gradientStart = SwiftUI.Color("LinearBG1")
            public let gradientEnd = SwiftUI.Color("LinearBG2")

            public init() {}
        }

        public struct Highlight {
            public let primary = SwiftUI.Color("Yellow")

            public init() {}
        }

        public struct AppleHealth {
            public let tint = UIColor.systemBlue

            public init() {}
        }
    }
}

extension UIColor {
    /// Create `UIColor` from hex string.
    /// - Parameter hex: Hex string value. Example `#1D2028`.
    public convenience init(hex: String) {
        guard let components = Self.parse(hex: "\(hex)") else {
            fatalError("Invalid hex format")
        }
        self.init(
            red: CGFloat(components.r) / 255,
            green: CGFloat(components.g) / 255,
            blue: CGFloat(components.b) / 255,
            alpha: CGFloat(components.a) / 255
        )
    }

    // swiftlint:disable:next large_tuple
    static func parse(hex: String) -> (r: UInt64, g: UInt64, b: UInt64, a: UInt64)? {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int = UInt64()
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3:
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6:
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        return (r, g, b, a)
    }
}

infix operator |: AdditionPrecedence

extension UIColor {
    static func | (lightMode: UIColor, darkMode: UIColor) -> UIColor {
        guard #available(iOS 13.0, *) else { return lightMode }

        return UIColor { traitCollection in
            traitCollection.userInterfaceStyle == .light ? lightMode : darkMode
        }
    }
}
