//
//  Activity.swift
//  bjjtracker
//
//  Created by Petro Hupalo on 05.04.2023.
//

import Foundation
import SwiftUI

enum ActivityType: String, CaseIterable, Hashable {
    case training = "Class"
    case competition = "Competition"
    case seminar = "Seminar"
    
    var color: Color {
        switch self {
        case .training:
            return DesignSystem.shared.colors.green
        case .competition:
            return DesignSystem.shared.colors.competition
        case .seminar:
            return DesignSystem.shared.colors.seminar
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
            return DesignSystem.shared.colors.purple
        case .ongoing:
            return DesignSystem.shared.colors.blue
        case .finished:
            return DesignSystem.shared.colors.green
        }
    }
    
}

class Activity: ObservableObject, Identifiable, Equatable {
    
    @Published var id = UUID()
    @Published var repeatableId: String?
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
    
    var totalEnergy: Int {
        Int(Double(duration) / 60 * 600)
    }
    
    init(id: UUID = UUID(), repeatableId: String? = nil, type: ActivityType, style: GraplingStyle, duration: Int, startDate: Date, location: String, notes: String) {
        self.id = id
        self.repeatableId = repeatableId
        self.type = type
        self.style = style
        self.duration = duration
        self.startDate = startDate
        self.location = location
        self.notes = notes
    }
}

extension Activity {
    static func from(session: SessionEntity) -> Activity? {
        guard let id = session.id,
              let type = session.type,
              var style = session.style,
              let startDate = session.startDate,
              let notes = session.notes
        else {
            return nil
        }
        if style == "No-Gi" {
            style = "No-gi"
        }
        return Activity(
            id: id,
            type: ActivityType(rawValue: type)!,
            style: GraplingStyle(rawValue: style)!,
            duration: Int(session.duration),
            startDate: startDate,
            location: session.location ?? "",
            notes: notes
        )
    }

    static func == (lhs: Activity, rhs: Activity) -> Bool {
        lhs.id == rhs.id
    }
}

extension SessionEntity {
    var status: ActivityStatus {
        let now = Date()
        let startDate = startDate ?? Date()
        if now >= startDate && now < (startDate + TimeInterval(duration * 60)) {
            return .ongoing
        } else if now > (startDate + TimeInterval(duration * 60)) {
            return .finished
        } else {
            return .upcoming
        }
    }
    
    var activityType: ActivityType {
        if ActivityType.allCases.contains(where: { $0.rawValue == type }) {
            return ActivityType(rawValue: type ?? "Class")!
        }
        return ActivityType(rawValue: "Class")!
    }

    var activityStyle: GraplingStyle {
        if GraplingStyle.allCases.contains(where: { $0.rawValue == style }) {
            return GraplingStyle(rawValue: style ?? "Gi")!
        }
        return GraplingStyle(rawValue: "Gi")!
    }
    
    static func == (lhs: SessionEntity, rhs: SessionEntity) -> Bool {
        lhs.id == rhs.id
    }
}
