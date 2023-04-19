//
//  Activity.swift
//  bjjtracker
//
//  Created by Petro Hupalo on 05.04.2023.
//

import Foundation
import SwiftUI

enum ActivityType: String, CaseIterable, Hashable {
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

enum GraplingStyle: String, CaseIterable, Hashable {
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

class Activity: Identifiable, Equatable, ObservableObject {
    
    var id = UUID()
    @Published var type: ActivityType
    @Published var style: GraplingStyle
    @Published var duration: Int
    @Published var startDate: Date
    @Published var location: String = ""
    @Published var notes: String = ""
    
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
    
    init(id: UUID = UUID(), type: ActivityType, style: GraplingStyle, duration: Int, startDate: Date, location: String, notes: String) {
        self.id = id
        self.type = type
        self.style = style
        self.duration = duration
        self.startDate = startDate
        self.location = location
        self.notes = notes
    }
}

extension Activity {
    static func from(session: Session) -> Activity? {
        guard let id = session.id,
              let type = session.type,
              let style = session.style,
              let duration = session.duration,
              let startDate = session.startDate,
              let notes = session.notes
        else {
            return nil
        }
        return Activity(
            id: id,
            type: ActivityType(rawValue: type)!,
            style: GraplingStyle(rawValue: style)!,
            duration: duration as! Int,
            startDate: startDate,
            location: session.location ?? "",
            notes: notes
        )
    }
    
    static func == (lhs: Activity, rhs: Activity) -> Bool {
        lhs.id == rhs.id
    }
}
