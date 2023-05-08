//
//  StatisticsViewPresenter.swift
//  bjjtracker
//
//  Created by Petro Hupalo on 19.04.2023.
//

import SwiftUI

struct StatisticsViewPresenter {
    let persistanceManager: ActivitiesReading = CoreDataService()
    
    var title: String = ""
    var isConcreteDates: Bool = false
    var previousPeriod: DateInterval
    
    @State var dateInterval: DateInterval = DateInterval(start: Calendar.current.date(byAdding: .day, value: -7, to: Date())!, end: Date())
    
    init(dateInterval: DateInterval) {
//        self.dateInterval = DateInterval(start: Calendar.current.date(byAdding: .day, value: -7, to: Date())!, end: Date())
        self.previousPeriod = DateInterval(start: dateInterval.start - dateInterval.duration, end: dateInterval.start)
        self.title = intervalToString(from: dateInterval.start, to: dateInterval.end)
    }
    
    mutating func update(dateInterval: DateInterval) {
        self.dateInterval = dateInterval
        self.title = intervalToString(from: dateInterval.start, to: dateInterval.end)
    }
    
//    func sessionsForInterval() -> [Activity] {
//        do {
//            return try persistanceManager.fetchActivities(from: dateInterval)
//        } catch let error {
//            print("sessionsForInterval error: \(error)")
//            return []
//        }
//    }
    
//    func totalTime() -> String {
//        return sessionsList.map { Int($0.duration) }.reduce(0, +).minutesToDuration()
//    }
//    
//    func sessions(by type: ActivityType) -> [Session] {
//        return sessionsList.filter({ $0.activityType == type })
//    }
//    
//    func sessions(by style: GraplingStyle) -> [Session] {
//        return sessionsList.filter({ $0.activityStyle == style })
//    }
}

extension StatisticsViewPresenter {
    func intervalToString(from: Date, to: Date) -> String {
        if from.isSame(as: to, by: [.day, .month, .year]) {
            return "\(to.toString("dd MMMM yyyy"))"
        } else if from.isSame(as: to, by: [.month, .year]) {
            return "\(from.toString("dd"))-\(to.toString("dd MMMM yyyy"))"
        } else if from.isSame(as: to, by: [.year]) {
            return "\(from.toString("dd MMMM"))-\(to.toString("dd MMMM yyyy"))"
        } else if Calendar.current.isDate(from, inSameDayAs: from.startOfMonth()) && Calendar.current.isDate(from, inSameDayAs: from.endOfMonth()) {
            return "\(to.toString("MMMM yyyy"))"
        } else {
            return "\(from.toString("dd MMMM yyyy"))-\(to.toString("dd MMMM yyyy"))"
        }
    }
}
