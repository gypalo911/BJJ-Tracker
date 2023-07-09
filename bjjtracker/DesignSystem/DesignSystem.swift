//
//  DesignSystem.swift
//  bjjtracker
//
//  Created by Petro Hupalo on 09.07.2023.
//

import Foundation
import SwiftUI

public final class DesignSystem {

    public typealias StyleSelector<T> = (T) -> Void

    public static let shared = DesignSystem()


    /// Defines spacers used throughout the application
    public let spacer = DesignSystem.Spacer()

    /// Defines colors used throughout the application
    public let color = DesignSystem.Color()

    /// Defines fonts used throughout the application
//    public let font = DesignSystem.Font()

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
