//
//  Promotion.swift
//  bjjtracker
//
//  Created by Petro Hupalo on 09.04.2023.
//

import SwiftUI

enum GradingSystem: String, CaseIterable {
    case junior = "Junior"
    case adult = "Adult"
}

protocol Belt: CaseIterable, Hashable {}

enum AdultBelts: String, CaseIterable, Identifiable {
    case white = "White"
    case blue = "Blue"
    case purple = "Purple"
    case brown = "Brown"
    case black = "Black"
    case none
    
    var id: String { self.rawValue }
    
    var color: (Color, Color?) {
        switch self {
        case .white:
            return (Color.white, nil)
        case .blue:
            return (Color.blue, nil)
        case .purple:
            return (Color.purple, nil)
        case .brown:
            return (Color(UIColor.brown), nil)
        case .black:
            return (Color.black, .red)
        case .none:
            return (.clear, nil)
        }
    }
}

enum JuniorBelts: String, CaseIterable, Identifiable {
    case GreyWhite = "Grey/White"
    case Grey = "Grey"
    case GreyBlack = "Grey/Black"
    case YellowWhite = "Yellow/White"
    case Yellow = "Yellow"
    case YellowBlack = "Yellow/Black"
    case OrangeWhite = "Orange/White"
    case Orange = "Orange"
    case OrangeBlack = "Orange/Black"
    case GreenWhite = "Green/White"
    case Green = "Green"
    case GreenBlack = "Green/Black"
    case none
    
    var id: String { self.rawValue }
    
    var color: (Color, Color?) {
        switch self {
        case .GreyWhite:
            return (Color.gray, Color.white)
        case .Grey:
            return (Color.gray, nil)
        case .GreyBlack:
            return (Color.gray, Color.black)
        case .YellowWhite:
            return (Color.yellow, Color.white)
        case .Yellow:
            return (Color.yellow, nil)
        case .YellowBlack:
            return (Color.yellow, Color.black)
        case .OrangeWhite:
            return (Color.orange, Color.white)
        case .Orange:
            return (Color.orange, nil)
        case .OrangeBlack:
            return (Color.orange, Color.black)
        case .GreenWhite:
            return (Color.green, Color.white)
        case .Green:
            return (Color.green, nil)
        case .GreenBlack:
            return (Color.green, Color.black)
        case .none:
            return (.clear, nil)
        }
    }
}

class Promotion: Identifiable, ObservableObject {
    var id = UUID()
    @Published var gradingSystem: GradingSystem {
        willSet {
            if gradingSystem == .adult {
                adultBelt = .none
            } else {
                juniorBelt = .none
            }
        }
    }
    @Published var adultBelt: AdultBelts
    @Published var juniorBelt: JuniorBelts
    @Published var stripes: Int
    @Published var date: Date
    @Published var location: String = ""
    @Published var notes: String = ""
    
    init(
        id: UUID = UUID(),
        gradingSystem: GradingSystem,
        adultBelt: AdultBelts = .none,
        juniorBelt: JuniorBelts = .none,
        stripes: Int,
        date: Date,
        location: String,
        notes: String
    ) {
        self.id = id
        self.gradingSystem = gradingSystem
        self.adultBelt = adultBelt
        self.juniorBelt = juniorBelt
        self.stripes = stripes
        self.date = date
        self.location = location
        self.notes = notes
    }
    
}

extension Promotion: Equatable {
    static func == (lhs: Promotion, rhs: Promotion) -> Bool {
        lhs.id == rhs.id
    }
}
