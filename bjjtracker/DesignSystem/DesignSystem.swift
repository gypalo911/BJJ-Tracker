//
//  DesignSystem.swift
//  bjjtracker
//
//  Created by Petro Hupalo on 09.07.2023.
//

import SwiftUI

public final class DesignSystem {

    public typealias StyleSelector<T> = (T) -> Void

    public static let shared = DesignSystem()

    /// Shared spacing tokens used throughout the application.
    public let spacing = DesignSystem.Spacing()

    /// Shared color tokens used throughout the application.
    public let colors = DesignSystem.Colors()

    /// Shared typography tokens used throughout the application.
    public let fonts = DesignSystem.Fonts()

    /// Backwards-compatible alias for older call sites.
    public var spacer: Spacing { spacing }

    /// Backwards-compatible alias for older call sites.
    public var color: Colors { colors }

    /// Backwards-compatible alias for older call sites.
    public var font: Fonts { fonts }

    /// Design device size must always be `812.0` or `iPhone 13 mini` in points.
    /// Used for fonts and element heights.
    public static let scaleFactor: CGFloat = {
        let benchmarkDeviceHeight: CGFloat = 812.0
        let actualDeviceHeight = UIScreen.main.bounds.height
        if actualDeviceHeight < benchmarkDeviceHeight {
            return 1.0
        }
        let scaleFactor = actualDeviceHeight / benchmarkDeviceHeight
        return scaleFactor
    }()
}
