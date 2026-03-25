//
//  DesignSystem+Spacer.swift
//  bjjtracker
//
//  Created by Petro Hupalo on 09.07.2023.
//

import CoreGraphics

extension DesignSystem {
    /// Defines shared spacing tokens used throughout the application.
    public struct Spacing {
        public let hairline: CGFloat = 2
        public let xSmall: CGFloat = 4
        public let small: CGFloat = 8
        public let smallMedium: CGFloat = 12
        public let medium: CGFloat = 16
        public let large: CGFloat = 20
        public let xLarge: CGFloat = 24
        public let xxLarge: CGFloat = 32
        public let huge: CGFloat = 48

        public let chipVertical: CGFloat = 8
        public let chipHorizontal: CGFloat = 20
        public let chipInputHorizontal: CGFloat = 15
        public let buttonHorizontal: CGFloat = 10
        public let screenInset: CGFloat = 20
        public let sectionSpacing: CGFloat = 30

        /// Backwards-compatible aliases for older call sites.
        public let xxs: CGFloat = 2
        public let xs: CGFloat = 4
        public let sm: CGFloat = 8
        public let mdsm: CGFloat = 12
        public let md: CGFloat = 16
        public let lg: CGFloat = 24
        public let xl: CGFloat = 32
        public let xxl: CGFloat = 48

        public init() {}
    }
}
