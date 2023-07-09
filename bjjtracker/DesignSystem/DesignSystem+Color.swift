//
//  DesignSystem+Color.swift
//  bjjtracker
//
//  Created by Petro Hupalo on 09.07.2023.
//

import Foundation
import SwiftUI

extension DesignSystem {
    /// Defines colors used throughout the application
    public struct Color {
        // Defaults to `#AC4C87`
        public let purpleMain = UIColor(hex: "#AC4C87")
        /// Activity indicator color
        /// Light defaults to `#1D2028`
        /// Dark defaults to `#FFFFFF`
        public let activityIndicator = UIColor(hex: "#1D2028") | UIColor(hex: "#FFFFFF")
        /// Default tint colors
        /// for Apple Health icons
        public let appleHealthTintColors = AppleHealthTintColors()

        public struct HeaderTileBackground {
            /// Defaults to `#C38F67`
            public let lightBrown = UIColor(hex: "#C38F67")
        }

        public struct AppleHealthTintColors {
            /// Defaults to `systemBlue`
            public let blue = UIColor.systemBlue
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
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        return (r, g, b, a)
    }
}

infix operator |: AdditionPrecedence
extension UIColor {

    /// Easily define two colors for both light and dark mode.
    /// - Parameters:
    ///   - lightMode: The color to use in light mode.
    ///   - darkMode: The color to use in dark mode.
    /// - Returns: A dynamic color that uses both given colors respectively for the given user interface style.
    static func | (lightMode: UIColor, darkMode: UIColor) -> UIColor {
        guard #available(iOS 13.0, *) else { return lightMode }

        return UIColor { (traitCollection) -> UIColor in
            return traitCollection.userInterfaceStyle == .light ? lightMode : darkMode
        }
    }
}
