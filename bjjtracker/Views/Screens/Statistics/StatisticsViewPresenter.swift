//
//  StatisticsViewPresenter.swift
//  bjjtracker
//
//  Created by Petro Hupalo on 19.04.2023.
//

import SwiftUI

struct StatisticsViewPresenter {
    let dateInterval: DateInterval
    let persistanceManager: ActivitiesReading = CoreDataService()
    
    var title: String = ""
    var isConcreteDates: Bool = true
    var previousPeriod: DateInterval
    
    init(dateInterval: DateInterval) {
        self.dateInterval = dateInterval
        self.previousPeriod = DateInterval(start: dateInterval.start - dateInterval.duration, end: dateInterval.start)
        self.title = intervalToString(from: dateInterval.start, to: dateInterval.end)
    }
    
    func sessionsForInterval() -> [Activity] {
        do {
            return try persistanceManager.fetchActivities(from: dateInterval)
        } catch let error {
            print("sessionsForInterval error: \(error)")
            return []
        }
    }
    
    func totalTime() -> String {
        return "\(sessionsForInterval().count)"
    }
    
    func sessions(by type: ActivityType) -> [Activity] {
        return sessionsForInterval().filter({ $0.type == type })
    }
    
    func sessions(by style: GraplingStyle) -> [Activity] {
        return sessionsForInterval().filter({ $0.style == style })
    }
}

private extension StatisticsViewPresenter {
    func intervalToString(from: Date, to: Date) -> String {
        if dateInterval.start.isSame(as: dateInterval.end, by: [.month, .year]) {
            return "\(dateInterval.start.toString("dd"))-\(dateInterval.end.toString("dd MMMM yyyy"))"
        } else if dateInterval.start.isSame(as: dateInterval.end, by: [.year]) {
            return "\(dateInterval.start.toString("dd MMMM"))-\(dateInterval.end.toString("dd MMMM yyyy"))"
        } else if Calendar.current.isDate(dateInterval.start, inSameDayAs: dateInterval.start.startOfMonth()) && Calendar.current.isDate(dateInterval.start, inSameDayAs: dateInterval.start.endOfMonth()) {
            return "\(dateInterval.end.toString("MMMM yyyy"))"
        } else {
            return "\(dateInterval.start.toString("dd MMMM yyyy"))-\(dateInterval.end.toString("dd MMMM yyyy"))"
        }
    }
}
