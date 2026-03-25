//
//  DesignSystem + Typography.swift
//  bjjtracker
//
//  Created by Petro Hupalo on 09.07.2023.
//

import Foundation
import UIKit

extension DesignSystem.Typography {
    enum Heading {
        case h1
        case h2
        case h3
        case h4
        case h5

        var token: DesignSystem.FontToken {
            switch self {
            case .h1:
                return DesignSystem.FontToken(size: 40, weight: .bold)
            case .h2:
                return DesignSystem.FontToken(size: 32, weight: .bold)
            case .h3:
                return DesignSystem.FontToken(size: 24, weight: .bold)
            case .h4:
                return DesignSystem.FontToken(size: 20, weight: .bold)
            case .h5:
                return DesignSystem.FontToken(size: 17, weight: .bold)
            }
        }
    }

    enum Body {
        enum FontWeight {
            case regular
            case bold
        }

        case b1(weight: FontWeight)
        case b2(weight: FontWeight)
        case countDown

        var token: DesignSystem.FontToken {
            switch self {
            case .b1(let weight):
                return DesignSystem.FontToken(size: 17, weight: weight.uiKitWeight)
            case .b2(let weight):
                return DesignSystem.FontToken(size: 15, weight: weight.uiKitWeight)
            case .countDown:
                return DesignSystem.FontToken(size: 36, weight: .regular)
            }
        }
    }

    enum SubText {
        case light
        case bold

        var token: DesignSystem.FontToken {
            switch self {
            case .light:
                return DesignSystem.FontToken(size: 13, weight: .regular)
            case .bold:
                return DesignSystem.FontToken(size: 13, weight: .bold)
            }
        }
    }

    enum Buttons {
        case regular
        case bold
        case small

        var token: DesignSystem.FontToken {
            switch self {
            case .regular:
                return DesignSystem.FontToken(size: 17, weight: .regular)
            case .bold:
                return DesignSystem.FontToken(size: 17, weight: .bold)
            case .small:
                return DesignSystem.FontToken(size: 14, weight: .bold)
            }
        }
    }

    enum Strikethrough {
        case b1
        case b2

        var token: DesignSystem.FontToken {
            switch self {
            case .b1:
                return DesignSystem.FontToken(size: 17, weight: .regular)
            case .b2:
                return DesignSystem.FontToken(size: 15, weight: .regular)
            }
        }
    }
}

private extension DesignSystem.Typography.Body.FontWeight {
    var uiKitWeight: UIFont.Weight {
        switch self {
        case .regular:
            return .regular
        case .bold:
            return .bold
        }
    }
}
