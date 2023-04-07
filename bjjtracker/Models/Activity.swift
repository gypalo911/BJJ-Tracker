//
//  Activity.swift
//  bjjtracker
//
//  Created by Petro Hupalo on 05.04.2023.
//

import Foundation
import SwiftUI

enum ActivityType: String {
    case session = "Class"
    case competition = "Competition"
    case seminar = "Seminar"
    
    var color: Color {
        switch self {
        case .session:
            return Color("Green")
        case .competition:
            return Color("Competition")
        case .seminar:
            return Color("Seminar")
        }
    }
}

enum GraplingStyle: String {
    case gi = "Gi"
    case noGi = "No-gi"
}

enum ActivityStatus: String {
    case upcoming = "UPCOMING"
    case ongoing = "ONGOING"
    case finished = "FINISHED"
    
    var color: Color {
        switch self {
        case .upcoming:
            return Color("Purple")
        case .ongoing:
            return Color("Blue")
        case .finished:
            return Color("Green")
        }
    }
    
}

struct Activity: Identifiable, Equatable {
    var id = UUID()
    var type: ActivityType
    var style: GraplingStyle
    var duration: Int
    var startDate: Date
    var location: String?
    var notes: String = ""
    
    var status: ActivityStatus {
        let now = Date()
        if now >= startDate && now < (startDate + TimeInterval(duration)) {
            return .ongoing
        } else if now > (startDate + TimeInterval(duration)) {
            return .finished
        } else {
            return .upcoming
        }
    }
}

extension Activity {
    static func from(session: Session) -> Activity? {
        guard let type = session.type,
              let style = session.style,
              let duration = session.duration,
              let startDate = session.startDate,
              let notes = session.notes
        else {
            return nil
        }
        return Activity(
            type: ActivityType(rawValue: type)!,
            style: GraplingStyle(rawValue: style)!,
            duration: duration as! Int,
            startDate: startDate,
            location: session.location,
            notes: notes
        )
    }
}
