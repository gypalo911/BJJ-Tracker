//
//  DesignSystem+Font.swift
//  bjjtracker
//
//  Created by Petro Hupalo on 09.07.2023.
//

import Foundation
import UIKit

extension DesignSystem {
    /// Defines font styles used throughout the application. Includes kerning value and line spacing.
    public enum FontStyle {
        case heading(CGFloat)
        case heading1
        case heading2
        case subtitle1
        case subtitle2
        case subtitle3
        case subtitle4
        case text1Medium
        case text1
        case text2Medium
        case text2
        case text3Medium
        case text3
        case text4Medium
        case text4
        case text5Medium
        case text5
        case tabBarItems

//        public var font: UIFont {
//            switch self {
//            case .heading(let size): return DesignSystem.shared.font.heading(size)
//            case .heading1:          return DesignSystem.shared.font.heading1
//            case .heading2:          return DesignSystem.shared.font.heading2
//            case .subtitle1:         return DesignSystem.shared.font.subtitle1
//            case .subtitle2:         return DesignSystem.shared.font.subtitle2
//            case .subtitle3:         return DesignSystem.shared.font.subtitle3
//            case .subtitle4:         return DesignSystem.shared.font.subtitle4
//            case .text1Medium:       return DesignSystem.shared.font.text1Medium
//            case .text1:             return DesignSystem.shared.font.text1
//            case .text2Medium:       return DesignSystem.shared.font.text2Medium
//            case .text2:             return DesignSystem.shared.font.text2
//            case .text3Medium:       return DesignSystem.shared.font.text3Medium
//            case .text3:             return DesignSystem.shared.font.text3
//            case .text4Medium:       return DesignSystem.shared.font.text4Medium
//            case .text4:             return DesignSystem.shared.font.text4
//            case .text5Medium:       return DesignSystem.shared.font.text5Medium
//            case .text5:             return DesignSystem.shared.font.text5
//            case .tabBarItems:       return DesignSystem.shared.font.tabBarItems
//            }
//        }

        var kerningValue: CGFloat? {
            switch self {
            case .heading, .heading1, .heading2:
                return 0.0
            default:
                return nil
            }
        }

        var lineSpacing: CGFloat? {
            switch self {
            case .heading, .heading1, .heading2, .tabBarItems:
                return 0.0
            case .subtitle1, .text1Medium, .text1:
                return 8.0
            case .text2Medium, .text2:
                return 8.0
            case .subtitle2, .text3Medium, .text3:
                return 8.0
            case .subtitle3, .text4Medium, .text4:
                return 8.0
            case .text5Medium, .text5:
                return 8.0
            case .subtitle4:
                return 8.0
            }
        }
    }
    
    public struct Font {
//        /// Defaults to `AkzidenzGroteskStd.boldCondensed`
//        public var heading: (CGFloat) -> UIFont = { size in
//            return FontFamily.AkzidenzGroteskStd.boldCondensed.font(size: size * scaleFactor)
//        }
//        /// Defaults to `AkzidenzGroteskStd.boldCondensed.font(size: 32)`
//        public let heading1 = FontFamily.AkzidenzGroteskStd.boldCondensed.font(size: 32 * scaleFactor)
    }
}
