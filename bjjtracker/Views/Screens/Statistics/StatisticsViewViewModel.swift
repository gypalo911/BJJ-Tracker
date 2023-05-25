//
//  StatisticsViewViewModel.swift
//  bjjtracker
//
//  Created by Petro Hupalo on 19.04.2023.
//

import SwiftUI

@MainActor
class StatisticsViewViewModel: ObservableObject {
    let persistanceManager: ActivitiesReading = CoreDataService()
    
    @Published var title: String = ""
    var isConcreteDates: Bool = false
    var previousPeriod: DateInterval
    
    @Published var dateInterval: DateInterval = DateInterval(start: Calendar.current.date(byAdding: .day, value: -7, to: Date())!, end: Date())
    @Published var selectedSegment: Int = CalendarSegment.week.rawValue
    
    init(dateInterval: DateInterval) {
        self.previousPeriod = DateInterval(start: dateInterval.start - dateInterval.duration, end: dateInterval.start)
        self.setupTitle()
    }
    
    func update(dateInterval: DateInterval) {
        self.dateInterval = dateInterval
    }
    
    func totalTime(_ sessions: [Session]) -> String {
        return sessions.map { Int($0.duration) }.reduce(0, +).minutesToDuration()
    }
    
    func sessions(by type: ActivityType, _ sessions: [Session]) -> [Session] {
        return sessions.filter({ $0.activityType == type })
    }
    
    func sessions(by style: GraplingStyle, _ sessions: [Session]) -> [Session] {
        return sessions.filter({ $0.activityStyle == style })
    }
    
    func initDates() {
        if selectedSegment == 0 {
            let start = Calendar.current.date(byAdding: .day, value: -7, to: Date().startOfDay)!
            let end = Date().startOfDay
            dateInterval = DateInterval(start: start, end: end)
        } else if selectedSegment == 1 {
            let start = Date().startOfMonth()
            let end = Date().endOfMonth()
            dateInterval = DateInterval(start: start, end: end)
        } else if selectedSegment == 2 {
            let currentYearStart = Calendar.current.date(from: Calendar.current.dateComponents([.year], from: Calendar.current.startOfDay(for: dateInterval.start)))!
            var currentYearEnd = Calendar.current.date(byAdding: .year, value: 1, to: currentYearStart)!
            currentYearEnd = Calendar.current.date(byAdding: .minute, value: -1, to: currentYearEnd)!
            dateInterval = DateInterval(start: currentYearStart, end: currentYearEnd)
        }
    }
    
    func plusInterval() {
        if selectedSegment == 0 {
            let start = dateInterval.end
            let end = Calendar.current.date(byAdding: .day, value: 7, to: dateInterval.end)!
            dateInterval = DateInterval(start: start, end: end)
        } else if selectedSegment == 1 {
            let start = Calendar.current.date(byAdding: .month, value: 1, to: dateInterval.end.startOfMonth())!
            let end = Calendar.current.date(byAdding: .month, value: 1, to: dateInterval.end.endOfMonth())!
            dateInterval = DateInterval(start: start, end: end)
        } else if selectedSegment == 2 {
            initDates()
            let start = Calendar.current.date(byAdding: .year, value: 1, to: dateInterval.start)!
            let end = Calendar.current.date(byAdding: .year, value: 1, to: dateInterval.end)!
            dateInterval = DateInterval(start: start, end: end)
        }
        setupTitle()
    }
    
    func minusInterval() {
        if selectedSegment == 0 {
            let start = Calendar.current.date(byAdding: .day, value: -7, to: dateInterval.start)!
            let end = dateInterval.start
            dateInterval = DateInterval(start: start, end: end)
        } else if selectedSegment == 1 {
            let startOfMonth = dateInterval.start.startOfMonth()
            let start = Calendar.current.date(byAdding: .month, value: -1, to: startOfMonth)!
            let end = start.endOfMonth()
            dateInterval = DateInterval(start: start, end: end)
        } else if selectedSegment == 2 {
            initDates()
            let start = Calendar.current.date(byAdding: .year, value: -1, to: dateInterval.start)!
            let end = Calendar.current.date(byAdding: .minute, value: -1, to: dateInterval.start)!
            dateInterval = DateInterval(start: start, end: end)
        }
        setupTitle()
    }
    
    func setupTitle() {
        title = intervalToString(from: dateInterval.start, to: dateInterval.end, segment: selectedSegment)
    }
    
    func selectSegment(segment: Int) {
        selectedSegment = segment
        initDates()
        setupTitle()
    }
}

extension StatisticsViewViewModel {
    func intervalToString(from: Date, to: Date, segment: Int) -> String {
        if segment == 0 {
            if from.isSame(as: to, by: [.day, .month, .year]) {
                return "\(to.toString("dd MMMM yyyy"))"
            } else if from.isSame(as: to, by: [.year]) {
                return "\(from.toString("dd MMMM"))-\(to.toString("dd MMMM yyyy"))"
            } else if Calendar.current.isDate(from, inSameDayAs: from.startOfMonth()) && Calendar.current.isDate(from, inSameDayAs: from.endOfMonth()) {
                return "\(to.toString("LLLL yyyy").capitalized)"
            } else {
                return "\(from.toString("dd MMMM yyyy"))-\(to.toString("dd MMMM yyyy"))"
            }
        } else if segment == 1 {
            return to.toString("LLLL yyyy").capitalized
        } else {
            return to.toString("yyyy")
        }
    }
}
