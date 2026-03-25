//
//  DesignSystem+Font.swift
//  bjjtracker
//
//  Created by Petro Hupalo on 09.07.2023.
//

import SwiftUI
import UIKit

extension DesignSystem {
    public enum Typography {}

    /// Defines shared typography tokens used throughout the application.
    public struct Fonts {
        public let largeTitle = FontToken(size: 34, weight: .bold)
        public let title = FontToken(size: 28, weight: .bold)
        public let title2 = FontToken(size: 22, weight: .bold)
        public let title3 = FontToken(size: 20, weight: .semibold)
        public let headline = FontToken(size: 17, weight: .semibold)
        public let body = FontToken(size: 17, weight: .regular)
        public let bodyBold = FontToken(size: 17, weight: .bold)
        public let footnote = FontToken(size: 13, weight: .regular)
        public let caption = FontToken(size: 12, weight: .regular)
        public let caption2 = FontToken(size: 11, weight: .regular)
        public let chip = FontToken(family: "Rubik", size: 14, fallbackWeight: .regular)

        public init() {}
    }

    public struct FontToken {
        public let family: String?
        public let size: CGFloat
        public let fallbackWeight: UIFont.Weight

        public init(
            family: String? = nil,
            size: CGFloat,
            weight: UIFont.Weight
        ) {
            self.family = family
            self.size = size
            self.fallbackWeight = weight
        }

        public init(
            family: String? = nil,
            size: CGFloat,
            fallbackWeight: UIFont.Weight
        ) {
            self.family = family
            self.size = size
            self.fallbackWeight = fallbackWeight
        }

        public var swiftUI: SwiftUI.Font {
            if let family, UIFont(name: family, size: scaledSize) != nil {
                return .custom(family, size: scaledSize)
            }
            return .system(size: scaledSize, weight: swiftUIWeight)
        }

        public var uiKit: UIFont {
            if let family, let font = UIFont(name: family, size: scaledSize) {
                return font
            }
            return .systemFont(ofSize: scaledSize, weight: fallbackWeight)
        }

        private var scaledSize: CGFloat {
            size * DesignSystem.scaleFactor
        }

        private var swiftUIWeight: SwiftUI.Font.Weight {
            switch fallbackWeight {
            case .ultraLight:
                return .ultraLight
            case .thin:
                return .thin
            case .light:
                return .light
            case .medium:
                return .medium
            case .semibold:
                return .semibold
            case .bold:
                return .bold
            case .heavy:
                return .heavy
            case .black:
                return .black
            default:
                return .regular
            }
        }
    }
}
