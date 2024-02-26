//
//  Promotion.swift
//  bjjtracker
//
//  Created by Petro Hupalo on 09.04.2023.
//

import SwiftUI

enum GradingSystem: String, CaseIterable {
    case junior = "junior"
    case adult = "adult"
}

enum Belt: Int, CaseIterable {
    case white
    case blue
    case purple
    case brown
    case black
    case GreyWhite
    case Grey
    case GreyBlack
    case YellowWhite
    case Yellow
    case YellowBlack
    case OrangeWhite
    case Orange
    case OrangeBlack
    case GreenWhite
    case Green
    case GreenBlack
    case none
    
    static let juniorBelts: [Belt] = [.GreyWhite, .Grey, .GreyBlack, .YellowWhite, .Yellow, .YellowBlack, .OrangeWhite, .Orange, .OrangeBlack, .GreenWhite, .Green, .GreenBlack]
    static let adultBelts: [Belt] = [.white, .blue, .purple, .brown, .black]
    
    var color: (Color, Color?) {
        switch self {
        case .white:
            return (Color.white, nil)
        case .blue:
            return (Color("DefaultBlue"), nil)
        case .purple:
            return (Color.purple, nil)
        case .brown:
            return (Color(UIColor.brown), nil)
        case .black:
            return (Color.black, .red)
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
            return (Color.clear, nil)
        }
    }
    
    var title: String {
        let result: String = {
            switch self {
            case .white: return "White"
            case .blue: return "Blue"
            case .purple: return "Purple"
            case .brown: return "Brown"
            case .black: return "Black"
            case .GreyWhite: return "Grey/White"
            case .Grey: return "Grey"
            case .GreyBlack: return "Grey/Black"
            case .YellowWhite: return "Yellow/White"
            case .Yellow: return "Yellow"
            case .YellowBlack: return "Yellow/Black"
            case .OrangeWhite: return "Orange/White"
            case .Orange: return "Orange"
            case .OrangeBlack: return "Orange/Black"
            case .GreenWhite: return "Green/White"
            case .Green: return "Green"
            case .GreenBlack: return "Green/Black"
            case .none: return ""
            }
        }()
        return result.localizedString
    }
    
    static func belts(for system: GradingSystem) -> [Belt] {
        system == .junior ? Belt.juniorBelts : Belt.adultBelts
    }
}

class Promotion: Identifiable, ObservableObject {
    var id = UUID()
    @Published var gradingSystem: GradingSystem = .adult {
        willSet {
            belt = .none
        }
    }
    @Published var belt: Belt
    @Published var stripes: Int
    @Published var date: Date
    @Published var location: String = ""
    @Published var notes: String = ""
    
    var beltType: GradingSystem {
        Belt.juniorBelts.contains(belt) ? .junior : .adult
    }
    
    init(
        id: UUID = UUID(),
        belt: Belt,
        stripes: Int,
        date: Date,
        location: String,
        notes: String
    ) {
        self.id = id
        self.belt = belt
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

extension Promotion {
    static func from(_ model: PromotionModel) -> Promotion {
        Promotion(
            id: model.id ?? UUID(),
            belt: Belt(rawValue: Int(model.belt)) ?? .white,
            stripes: Int(model.stripes),
            date: model.date ?? Date(),
            location: model.location ?? "",
            notes: model.notes ?? ""
        )
    }
}
